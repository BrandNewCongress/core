defmodule Core.EventsController do
  use Core.Web, :controller
  require Logger

  def get(conn, params) do
    district = get_district(params["district"] || conn.cookies["district"])
    {:ok, coordinates} =
      district
      |> get_coordinates()
      |> Poison.encode()

    render conn, "events.html",
      [district: district, coordinates: coordinates, title: "Events"] ++ GlobalOpts.get(conn, params)
  end

  def get_one(conn, params = %{"slug" => slug}) do
    event =
      :event_cache
      |> Stash.get(slug)

    event =
      case event do
        nil -> nil
        event -> Osdi.Event.add_date_line(event)
      end

    banner = get_banner(event.type)
    
    render conn, "rsvp.html", [event: event, title: event.title, description: event.description, banner: banner] ++ GlobalOpts.get(conn, params)
  end

  def rsvp(conn, params = %{"slug" => slug,
    "first_name" => first_name, "last_name" => last_name,
    "email" => email, "phone" => phone, "address1" => address1,
    "zip" => zip, "city" => city, "state" => state}) do

    event =
      :event_cache
      |> Stash.get(slug)
      |> Osdi.Event.add_date_line()

    banner = get_banner(event.type)

    Nb.Events.Rsvps.create(event.id,
      %{"first_name" => first_name, "last_name" => last_name, "email" => email,
        "phone" => phone, "primary_address" => %{"address1" => address1, "zip" => zip,
        "city" => city, "state" => state}})

    render conn, "rsvp.html", [event: event, person: true, title: event.title, description: event.description, banner: banner] ++ GlobalOpts.get(conn, params)
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
    IO.inspect event_type

    "Event Type: " <> event_type
    |> String.downcase()
    |> String.replace(" ", "-")
    |> String.replace(":", "")
  end
end
