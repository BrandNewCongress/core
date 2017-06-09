defmodule Core.PageController do
  use Core.Web, :controller

  defp get_brand(conn, params) do
    cond do
      params["brand"] == "jd" -> "jd"
      true -> "bnc"
    end
  end

  defp get_platform(brand) do
    %{body: {:ok, %{"object" => %{
      "content" => html
    }}}} = Cosmic.get "#{brand}-platform"

    html
  end

  def index(conn, params) do
    render conn, "index.html", [brand: get_brand(conn, params)]
  end

  def platform(conn, params) do
    brand = get_brand(conn, params)
    html = get_platform(brand)
    render conn, "platform.html", [html: html, brand: brand]
  end
end
