defmodule Core.EventsChannel do
  use Phoenix.Channel
  require Logger

  def join("events", _message, socket) do
    {:ok, socket}
  end

  def handle_in("ready", _body, socket) do
    :event_cache
    |> Stash.get("all_slugs")
    |> Enum.each(fn slug -> slug |> fetch_event() |> push_event(socket) end)

    {:noreply, socket}
  end

  defp fetch_event(slug) do
    Stash.get(:event_cache, slug)
  end

  defp push_event(event, socket) do
    push socket, "event", %{"event" => event}
  end
end
