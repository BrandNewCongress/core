defmodule Core.Jobs.EventCache do
  require Logger
  import Ecto.Query

  @attrs ~w(
    id start_date end_date featured_image_url location summary title name
    type status description contact type location tags instructions
  )a

  def update do
    Logger.info("Updating event cache")

    # Fetch all events
    all_events = EventProxy.stream("events")
      |> Enum.map(fn e ->
        e
        |> Map.put(:start_date, EventHelp.parse(e.start_date))
        |> Map.put(:end_date, EventHelp.parse(e.end_date))
      end)
      |> Enum.filter(fn e ->
        e.status == "confirmed" and Timex.after?(e.start_date, Timex.now())
      end)
      |> Enum.map(&EventHelp.add_date_line/1)

    # Cache each by slug
    all_events |> Enum.each(&cache_by_name/1)

    # Cache all slugs as part of all
    Stash.set(:event_cache, "all_slugs", Enum.map(all_events, fn %{name: name} -> name end))

    # Filter each by calendar

    # Filter each by calendar
    all_tags = Enum.flat_map(all_events, & &1.tags)

    Enum.filter(all_tags, & String.contains?(&1, "Calendar:"))
    |> Enum.each(fn calendar ->
         calendar |> events_for_calendar(all_events) |> cache_calendar(calendar)
       end)

    Stash.persist(:event_cache, "event_cache")
    Logger.info("Updated event cache on #{Timex.now() |> DateTime.to_iso8601()}")

    all_events
  end

  def load_cached do
    Stash.load(:event_cache, "event_cache")
  end

  def fetch_or_load do
    try do
      update()
    rescue
      _e -> load_cached()
    end
  end

  defp cache_by_name(event) do
    Stash.set(:event_cache, event.name, event)
  end

  defp events_for_calendar(selected_calendar, events) do
    Enum.filter(events, fn %{tags: tags} ->
      Enum.member?(tags, selected_calendar)
    end)
  end

  defp cache_calendar(events, calendar) do
    Stash.set(:event_cache, calendar, Enum.map(events, fn %{name: slug} -> slug end))
  end
end
