defmodule Core.EventsChannel do
  use Phoenix.Channel
  require Logger

  def join("events", _message, socket) do
    {:ok, socket}
  end

  def handle_in("ready", %{"district" => district}, socket) do
    events = :event_cache |> Stash.get("all_slugs") |> Enum.map(&fetch_event/1)
    Enum.each(events, fn event -> push_event(event, socket) end)

    check_no_events(district, socket)

    {:noreply, socket}
  end

  def handle_in("ready", _body, socket) do
    events = :event_cache |> Stash.get("all_slugs") |> Enum.map(&fetch_event/1)
    Enum.each(events, fn event -> push_event(event, socket) end)

    {:noreply, socket}
  end

  def handle_in("get-district-overlay", %{"district" => district}, socket) do
    polygon = District.get_polygon_of(district)
    push(socket, "district-overlay", %{"polygon" => Geo.JSON.encode(polygon)})

    check_no_events(district, socket)

    {:noreply, socket}
  end

  defp fetch_event(slug) do
    Stash.get(:event_cache, slug)
  end

  defp push_event(event, socket) do
    push(socket, "event", %{"event" => event})
  end

  defp check_no_events(district, socket) do
    events = :event_cache |> Stash.get("all_slugs") |> Enum.map(&fetch_event/1)

    centroid = District.centroid(district)

    near_user =
      Enum.filter(events, fn
        %{location: %{location: %Geo.Point{coordinates: {lat, lng}}}} ->
          District.naive_distance_in_miles({lng, lat}, centroid) < 20

        _else ->
          false
      end)

    if length(near_user) < 1 do
      push(socket, "no-events", %{})
    end
  end
end
