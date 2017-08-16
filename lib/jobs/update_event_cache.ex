defmodule Core.Jobs.EventCache do
  require Logger

  def update do
    Logger.info "Updating event cache"

    # Fetch all events
    all_events =
      Nb.Events.stream_all()
      |> Enum.filter(&published_only/1)
      |> Enum.map(&Osdi.Event.from_nb/1)

    # Cache each by slug
    all_events |> Enum.each(&cache_by_name/1)

    # Cache all slugs as part of all
    all_slugs = Enum.map all_events, fn %{name: name} -> name end
    Stash.set(:event_cache, "all_slugs", all_slugs)

    # Filter each by calendar
    "candidates"
    |> Cosmic.get_type()
    |> Enum.map(fn %{"metadata" => %{"calendar_id" => calendar_id}} -> calendar_id end)
    |> MapSet.new()
    |> Enum.each(fn calendar -> calendar |> events_for_calendar(all_events) |> cache_calendar(calendar) end)

    Stash.persist(:event_cache, "event_cache")
    Logger.info "Updated event cache on #{Timex.now() |> DateTime.to_iso8601()}"

    all_events
  end

  def load_cached do
    Stash.load(:event_cache, "event_cache")
  end

  def fetch_or_load do
    try do
      update()
    rescue
      _e in KeyError -> load_cached()
      _e in FunctionClauseError -> load_cached()
    end
  end

  defp cache_by_name(event) do
    Stash.set(:event_cache, event.name, event)
  end

  defp events_for_calendar(selected_calendar, events) do
    Enum.filter events, fn %{calendar: calendar} -> selected_calendar == calendar end
  end

  defp cache_calendar(events, calendar) do
    Stash.set :event_cache, "calendar-#{calendar}", Enum.map(events, fn
      %{name: slug} -> slug
    end)
  end

  defp published_only(%{"status" => "published"}), do: true
  defp published_only(%{"status" => _something_else}), do: false
end
