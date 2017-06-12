defmodule Core.PageController do
  use Core.Web, :controller

  defp get_brand(conn, params) do
    cond do
      params["brand"] == "jd" -> "jd"
      true -> "bnc"
    end
  end

  defp is_mobile?(conn, _params) do
    case List.keyfind(conn.req_headers, "user-gent", 0, "") do
      { head, tail } -> Browser.mobile?(tail)
      _ -> false
    end
  end

  defp core_opts(conn, params) do
    [brand: get_brand(conn, params), mobile: is_mobile?(conn, params), conn: conn]
  end

  defp get_platform(brand) do
    %{body: {:ok, %{"object" => %{
      "content" => html
    }}}} = Cosmic.get "#{brand}-platform"

    html
  end

  def index(conn, params) do
    render conn, "index.html", core_opts(conn, params)
  end

  def platform(conn, params) do
    brand = get_brand(conn, params)
    html = get_platform(brand)
    render conn, "platform.html", [html: html] ++ core_opts(conn, params)
  end
end
