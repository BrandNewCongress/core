defmodule Cosmic.Api do
  use HTTPotion.Base

  defp process_url(url) do
    cond do
      String.length(url) > 0 ->
        "https://api.cosmicjs.com/v1/brand-new-congress/object/#{url}"
      true ->
        "https://api.cosmicjs.com/v1/brand-new-congress"
    end
  end

  defp process_response_body(raw) do
    Poison.decode(raw)
  end
end
