defmodule Core.EventsController do
  use Core.Web, :controller
  require Logger
  import ShorterMaps
  alias Osdi.{Attendance, Address, Event, Repo}

  @secret Application.get_env(:core, :update_secret)

  def get(conn, params) do
    district = get_district(params["district"] || conn.cookies["district"])

    {:ok, coordinates} =
      district
      |> get_coordinates()
      |> Poison.encode()

    render(
      conn,
      "events.html",
      [district: district, coordinates: coordinates, title: "Events"] ++
        GlobalOpts.get(conn, params)
    )
  end

  def iframe(conn, params = %{"district" => district}) do
    {:ok, coordinates} =
      district
      |> get_coordinates()
      |> Poison.encode()

    conn
    |> delete_resp_header("x-frame-options")
    |> render(
         "embedded.html",
         [
           layout: {Core.LayoutView, "bare.html"},
           district: district,
           coordinates: coordinates,
           title: "Events in #{district}"
         ] ++ GlobalOpts.get(conn, params)
       )
  end

  def iframe(conn, params) do
    {:ok, coordinates} = nil |> get_coordinates() |> Poison.encode()

    conn
    |> delete_resp_header("x-frame-options")
    |> render(
         "embedded.html",
         [
           layout: {Core.LayoutView, "bare.html"},
           district: "",
           coordinates: coordinates,
           title: "Events"
         ] ++ GlobalOpts.get(conn, params)
       )
  end

  def get_one(conn, params = %{"name" => event_name}) do
    event =
      case Stash.get(:event_cache, event_name) do
        nil -> nil
        event -> event
      end

    banner = get_banner(event.type)

    render(
      conn,
      "rsvp.html",
      [event: event, title: event.title, description: event.description, banner: banner] ++
        GlobalOpts.get(conn, params)
    )
  end

  def rsvp(
        conn,
        params = %{
          "slug" => event_name,
          "name" => name,
          "email" => email,
          "phone" => phone,
          "zip" => zip
        }
      ) do
    global_opts = GlobalOpts.get(conn, params)

    [first_name, last_name] =
      case String.split(name, ",") do
        [single] -> [single, ""]
        list = [_ | _] -> [List.first(list), List.last(list)]
        _ -> ["", ""]
      end

    event = Stash.get(:event_cache, event_name)
    banner = get_banner(event.type)

    spawn(fn ->
      Core.EventMailer.on_rsvp(
        event,
        ~m{first_name, last_name, email},
        Keyword.get(global_opts, :brand)
      )
    end)

    referrer_data = Map.merge(get_source(params), get_referrer(conn))

    attendance =
      %{given_name: first_name, family_name: last_name}
      |> add_if_exists(:email_address, email, email)
      |> add_if_exists(:phone_number, phone, phone)
      |> add_if_exists(:postal_address, zip, %Address{postal_code: zip})

    Attendance.push(event.id, attendance, referrer_data)

    render(
      conn,
      "rsvp.html",
      [
        event: event,
        person: true,
        title: event.title,
        description: event.description,
        banner: banner
      ] ++ global_opts
    )
  end

  defp add_if_exists(map, key, test, val) do
    if test != nil and test != "" do
      Map.put(map, key, val)
    else
      map
    end
  end

  defp get_source(%{"ref" => ref}), do: %{source: ref}
  defp get_source(_params), do: %{}

  defp get_referrer(conn) do
    case get_req_header(conn, "referrer") do
      nil -> %{}
      [] -> %{}
      url -> %{referrer: url}
    end
  end

  defp get_district(""), do: nil
  defp get_district(nil), do: nil

  defp get_district(district) do
    district
    |> String.upcase()
    |> District.normalize()
  end

  defp get_coordinates(nil), do: [38.805470223177466, -100.23925781250001]

  defp get_coordinates(district) do
    {:ok, coordinates} =
      district
      |> District.centroid()
      |> Tuple.to_list()
      |> (fn [y, x] -> [x, y] end).()
      |> Poison.encode()

    coordinates
  end

  defp get_banner(nil) do
    nil
  end

  defp get_banner(event_type) do
    event_type
    |> slugize()
    |> Cosmic.get()
    |> Kernel.get_in(["metadata", "preview", "imgix_url"])
  end

  defp slugize(event_type) do
    ("Event Type: " <> event_type)
    |> String.downcase()
    |> String.replace(" ", "-")
    |> String.replace(":", "")
    |> String.replace(",", "")
  end

  def as_json(conn, params = %{"candidate" => candidate}) do
    brand = conn |> GlobalOpts.get(params) |> Keyword.get(:brand)

    candidate = String.downcase(candidate)

    candidate =
      case candidate do
        "alexandria-ocasio" -> "alexandria-ocasio-cortez"
        other -> other
      end

    %{"title" => title} = Cosmic.get(candidate)

    slugs = Stash.get(:event_cache, "Calendar: #{title}") || []

    events =
      slugs
      |> Enum.map(fn slug -> Stash.get(:event_cache, slug) end)
      |> Enum.sort(&EventHelp.date_compare/2)
      |> Enum.map(&EventHelp.add_date_line/1)
      |> Enum.map(&EventHelp.add_candidate_attr/1)

    events =
      if params["secret"] == @secret do
        Enum.map(events, &add_secret_attrs/1)
      else
        events
      end

    json(conn, events)
  end

  def as_json(conn, params) do
    brand = conn |> GlobalOpts.get(params) |> Keyword.get(:brand)

    events =
      :event_cache
      |> Stash.get("all_slugs")
      |> Enum.map(fn slug -> Stash.get(:event_cache, slug) end)
      |> Enum.sort(&EventHelp.date_compare/2)
      |> Enum.map(&EventHelp.add_date_line/1)
      |> Enum.map(&EventHelp.add_candidate_attr/1)

    events =
      if params["secret"] == @secret do
        Enum.map(events, &add_secret_attrs/1)
      else
        events
      end

    json(conn, events)
  end

  defp add_secret_attrs(event = %{id: id}) do
    organizer_id = Repo.one(from(e in Event, where: e.id == ^id, select: e.organizer_id))
    organizer_edit_hash = Cipher.encrypt("#{organizer_id}")
    organizer_edit_url = "https://admin.justicedemocrats.com/my-events/#{organizer_edit_hash}"

    event
    |> Map.put(
         :rsvp_download_url,
         "https://admin.justicedemocrats.com/rsvps/#{Event.rsvp_link_for(event.name)}"
       )
    |> Map.put(:organizer_edit_url, organizer_edit_url)
  end
end
