defmodule EventHelp do
  def add_date_line(event) do
    date_line =
      humanize_date(event.start_date, event.location.time_zone) <> "from " <>
      humanize_time(event.start_date, event.location.time_zone) <> " - " <>
      humanize_time(event.end_date, event.location.time_zone)

    Map.put(event, :date_line, date_line)
  end

  defp humanize_date(dt, time_zone) do
    %DateTime{month: month, day: day} = get_zoned_dt(dt, time_zone)

    month = ["January", "February", "March", "April", "May", "June", "July",
             "August", "September", "October", "November", "December"] |> Enum.at(month - 1)

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
end
