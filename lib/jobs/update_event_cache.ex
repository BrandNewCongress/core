defmodule Core.Jobs.EventCache do
  require Logger
  alias Osdi.{Repo, Event, Tag}
  import Ecto.Query

  @attrs ~w(
    id start_date end_date featured_image_url location summary title name
    type status description host type logation tags
  )a

  def update do
    Logger.info "Updating event cache"

    # Fetch all events
    all_events =
      (from e in Event, where: e.status == "confirmed" and e.end_date > ^NaiveDateTime.utc_now())
      |> Repo.all()
      |> Repo.preload([:tags, :location])
      |> Enum.map(fn ev -> Map.take(ev, @attrs) end)

    # Cache each by slug
    all_events |> Enum.each(&cache_by_name/1)

    # Cache all slugs as part of all
    Stash.set :event_cache, "all_slugs", (Enum.map all_events, fn %{name: name} -> name end)

    # Filter each by calendar
    (from t in Tag, where: like(t.name, "Calendar: "))
    |> Repo.all()
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
      _e -> load_cached()
    end
  end

  defp cache_by_name(event) do
    Stash.set(:event_cache, event.name, event)
  end

  defp events_for_calendar(selected_calendar, events) do
    Enum.filter events, fn %{tags: tags} ->
      tags
      |> Enum.map(&(&1.name))
      |> Enum.member?(selected_calendar)
    end
  end

  defp cache_calendar(events, calendar) do
    Stash.set :event_cache, "calendar-#{calendar}", Enum.map(events, fn
      %{name: slug} -> slug
    end)
  end
end
