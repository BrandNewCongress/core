defmodule Core.EventsChannel do
  use Phoenix.Channel
  require Logger

  def join("events", _message, socket) do
    {:ok, socket}
  end

  def handle_in("ready", %{"district" => district}, socket) do
    events = Stash.get(:event_cache, "all_slugs")
    Enum.each events, fn slug ->
      slug |> fetch_event() |> push_event(socket)
    end

    {_key, centroid} = District.centroid(district)

    near_user = Enum.filter events, fn
      %{location: %{latitude: lat, longitude: lng}} ->
        District.naive_distance({lat, lng}, centroid) < 20
      _else ->
        false
    end

    if length(near_user) < 1 do
      push socket, "no-events", %{}
    end

    {:noreply, socket}
  end

  def handle_in("get-district-overlay", %{"district" => district}, socket) do
    polygon = District.get_polygon_of(district)
    push socket, "district-overlay", %{"polygon" => Geo.JSON.encode(polygon)}

    {:noreply, socket}
  end

  defp fetch_event(slug) do
    Stash.get(:event_cache, slug)
  end

  defp push_event(event, socket) do
    push socket, "event", %{"event" => event}
  end
end
