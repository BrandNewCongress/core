defmodule Maps do
  use HTTPotion.Base

  @key Application.get_env(:core, :goog_key)
  @default_params %{
    key: @key
  }

  defp process_url(url) do
    "https://maps.googleapis.com/maps/api/" <> url
  end

  defp process_request_headers(hdrs) do
    Enum.into(hdrs, ["Accept": "application/json", "Content-Type": "application/json"])
  end

  defp process_options(opts) do
    opts
    |> Keyword.update(:query, @default_params, &(Map.merge(@default_params, &1)))
  end

  defp process_response_body(raw) do
    case Poison.decode(raw) do
      {:ok, body} -> body
      {:error, raw} -> {:error, raw}
    end
  end

  defp process_request_body(body) do
    body
  end

  def geocode(address) do
    %{body: %{"results" => [%{"geometry" => %{"location" => location}} | _]}}
      = Maps.get("geocode/json", [query: %{"address" => address}])

    %{"lat" => lat, "lng" => lng} = location
    {lat, lng}
  end

  def time_zone_of({x, y}) do
    %{body: %{
      "dstOffset" => dst_offset, "rawOffset" => raw_offset,
      "timeZoneId" => time_zone_id, "timeZoneName" => time_zone_name
    }}
      = Maps.get(
          "timezone/json",
          [query: %{"location" => "#{x},#{y}",
                    "timestamp" => DateTime.utc_now() |> DateTime.to_unix()}])

    %{utc_offset: raw_offset + dst_offset, time_zone_id: time_zone_id,
      time_zone: time_zone_name, zone_abbr: abbreviate_zone(time_zone_name)}
  end

  def time_zone_of(address_string) do
    address_string
    |> geocode()
    |> time_zone_of()
  end

  defp abbreviate_zone(time_zone) do
    time_zone
    |> String.split(" ")
    |> Enum.map(fn word -> String.slice(word, 0..0) end)
  end
end
