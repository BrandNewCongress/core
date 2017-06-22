defmodule Cosmic.Api do
  use HTTPotion.Base

  defp process_url(url) do
    if String.length(url) > 0 do
      "https://api.cosmicjs.com/v1/brand-new-congress/object/#{url}"
    else
      "https://api.cosmicjs.com/v1/brand-new-congress"
    end
  end

  defp process_response_body(raw) do
    Poison.decode(raw)
  end
end
