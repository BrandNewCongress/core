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
    event = Stash.get(:event_cache, slug)
    date_line = humanize_date(event.start_date) <> humanize_time(event.start_date) <> " - " <> humanize_time(event.end_date)
    event = Map.put(event, :date_line, date_line)

    IO.inspect event

    render conn, "rsvp.html", [event: event] ++ GlobalOpts.get(conn, params)
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

  def humanize_time(iso_string) do
    {:ok, %{month: month, day: day, year: year, minute: minute, hour: hour}, offset} = DateTime.from_iso8601(iso_string)
    dt = %DateTime{month: month, day: day, year: year, utc_offset: offset, hour: hour, minute: minute, second: 0, time_zone: "", zone_abbr: "", std_offset: 0}
    %DateTime{hour: hour, minute: minute} = dt

    {hour, am_pm} = if hour >= 12, do: {hour - 12, "PM"}, else: {hour, "AM"}
    minute = if minute == 0, do: "", else: ": ${minute}"

    "#{hour}#{minute} " <> am_pm
  end

  def humanize_date(iso_string) do
    {:ok, %{month: month, day: day, year: year, minute: minute, hour: hour}, offset} = DateTime.from_iso8601(iso_string)
    dt = %DateTime{month: month, day: day, year: year, utc_offset: offset, hour: hour, minute: minute, second: 0, time_zone: "", zone_abbr: "", std_offset: 0}
    %DateTime{month: month, day: day} = dt

    month = ["January", "February", "March", "April", "May", "June", "July",
             "August", "September", "October", "November", "December"] |> Enum.at(month)

    "#{month} #{day} "
  end

end
