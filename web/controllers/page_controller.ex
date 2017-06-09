defmodule Core.PageController do
  use Core.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  defp get_platform() do
    %{body: {:ok, %{"object" => %{
      "content" => html
    }}}} = Cosmic.get "platform"

    html
  end

  def platform(conn, %{"brand" => "jd"}) do
    html = get_platform()
    render conn, "platform.jd.html", [html: html]
  end

  def platform(conn, _params) do
    html = get_platform()
    render conn, "platform.bnc.html", [html: html]
  end
end
