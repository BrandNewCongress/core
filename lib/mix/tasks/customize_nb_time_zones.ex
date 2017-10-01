defmodule Mix.Tasks.CustomizeNbTimeZones do
  @moduledoc """

  Important: This is a legacy task using a deprecated nationbuilder interface

  """
  use Mix.Task

  def run(_) do
    Nb.Events.stream_all()
    |> Stream.filter(&has_complete_location/1)
    |> Stream.filter(&missing_zone_tag/1)
    |> Stream.map(&extract_location/1)
    |> Stream.map(&time_zone_preserve_tuple/1)
    |> Stream.map(&write_new_zone/1)
    |> Enum.to_list()
  end

  defp has_complete_location(%{"venue" => %{"address" => %{"lat" => _lat, "lng" => _lng}}}), do: true
  defp has_complete_location(_e), do: false

  defp missing_zone_tag(%{"tags" => tags}) do
    num_zone_tags =
      tags
      |> Enum.filter(fn tag -> tag =~ "Event Time Zone:" end)
      |> length()

    num_zone_tags == 0
  end

  defp extract_location(event = %{"venue" => %{"address" => %{"lat" => lat_string, "lng" => lng_string}}}) do
    {lat, _} = Float.parse(lat_string)
    {lng, _} = Float.parse(lng_string)
    {event, {lat, lng}}
  end

  defp time_zone_preserve_tuple({event, lat_lng}) do
    {event, Maps.time_zone_of(lat_lng)}
  end

  defp write_new_zone({event = %{"id" => id}, %{time_zone_id: time_zone_id}}) do
    new_event = Map.put(event, "tags", event["tags"] ++ ["Event Time Zone: #{time_zone_id}"])
    Nb.Events.update(id, new_event)
  end
end
