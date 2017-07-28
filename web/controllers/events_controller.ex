defmodule Core.EventsController do
  use Core.Web, :controller

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
      |> Osdi.Event.add_date_line()

    render conn, "rsvp.html", [event: event] ++ GlobalOpts.get(conn, params)
  end

  def rsvp(conn, params = %{"slug" => slug, "first_name" => first_name, "last_name" => last_name, "email" => email, "phone" => phone}) do
    event =
      :event_cache
      |> Stash.get(slug)
      |> Osdi.Event.add_date_line()

    Nb.Events.Rsvps.create(event.id, %{"first_name" => first_name, "last_name" => last_name, "email" => email, "phone" => phone})

    render conn, "rsvp.html", [event: event, person: true] ++ GlobalOpts.get(conn, params)
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

end
