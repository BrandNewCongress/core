defmodule Entity do
  use HTTPotion.Base

  @key Application.get_env(:core, :goog_key)
  @default_params %{
    key: @key
  }

  defp process_url(url) do
    "https://kgsearch.googleapis.com/v1/entities:search" <> url
  end

  defp process_request_headers(hdrs) do
    Enum.into(hdrs, Accept: "application/json", "Content-Type": "application/json")
  end

  defp process_options(opts) do
    opts
    |> Keyword.update(:query, @default_params, &Map.merge(@default_params, &1))
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

  def search(query) do
    get("/", query: %{query: query})
  end
end
