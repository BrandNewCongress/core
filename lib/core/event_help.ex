defmodule EventHelp do
  def events_for(calendar) do
    try do
      :event_cache
      |> Stash.get("Calendar: #{calendar}")
      |> Enum.map(fn slug -> Stash.get(:event_cache, slug) end)
      |> Enum.sort(&EventHelp.date_compare/2)
      |> Enum.map(&EventHelp.add_date_line/1)
    rescue
      _e -> []
    end
  end

  def add_date_line(event) do
    date_line =
      humanize_date(event.start_date, event.location.time_zone) <>
        "from " <>
        humanize_time(event.start_date, event.location.time_zone) <>
        " - " <> humanize_time(event.end_date, event.location.time_zone)

    Map.put(event, :date_line, date_line)
  end

  defp humanize_date(dt, time_zone) do
    %DateTime{month: month, day: day} = get_zoned_dt(dt, time_zone)

    month =
      [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      ]
      |> Enum.at(month - 1)

    "#{month}, #{day} "
  end

  defp humanize_time(dt, time_zone) do
    %DateTime{hour: hour, minute: minute} = get_zoned_dt(dt, time_zone)

    {hour, am_pm} = if hour >= 12, do: {hour - 12, "PM"}, else: {hour, "AM"}
    hour = if hour == 0, do: 12, else: hour
    minute = if minute == 0, do: "", else: ":#{minute}"

    "#{hour}#{minute} " <> am_pm
  end

  defp get_zoned_dt(dt, time_zone) do
    dt
    |> Timex.Timezone.convert(time_zone |> Timex.Timezone.get(Timex.now()))
  end

  def set_browser_url(ev = %{name: name}), do: Map.put(ev, :browser_url, "/events/#{name}")

  def date_compare(%{start_date: d1}, %{start_date: d2}) do
    case DateTime.compare(d1, d2) do
      :gt -> false
      _ -> true
    end
  end

  def add_candidate_attr(event) do
    candidate =
      event.tags
      |> Enum.filter(&String.contains?(&1, "Calendar: "))
      |> Enum.map(&(&1 |> String.split(":") |> List.last() |> String.trim()))
      |> Enum.reject(&(&1 == "Brand New Congress" or &1 == "Justice Democrats"))
      |> List.first()

    candidate = candidate || "Justice Democrats"
    Map.put(event, :candidate, candidate)
  end

  def destructure_tags(event) do
    destructured = Enum.map(event.tags, fn %{name: name} -> name end)
    Map.put(event, :tags, destructured)
  end
end
