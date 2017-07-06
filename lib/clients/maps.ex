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
    Dict.merge(hdrs, [
        "Accept": "application/json",
        "Content-Type": "application/json"
      ])
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
    %{body: %{"results" => [%{"geometry" => %{"location" => location}} | _]}} = Maps.get("geocode/json", [query: %{"address" => address}])
    %{"lat" => lat, "lng" => lng} = location
    {lat, lng}
  end
end
