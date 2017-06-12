defmodule Cosmic.Api do
  use HTTPotion.Base

  defp process_url(url) do
    "https://api.cosmicjs.com/v1/brand-new-congress/object/#{url}"
  end

  defp process_response_body(raw) do
    Poison.decode(raw)
  end
end
