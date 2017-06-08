defmodule Core.PageController do
  use Core.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def platform(conn, %{"brand" => "jd"}) do
    render conn, "platform.jd.html"
  end

  def platform(conn, _params) do
    render conn, "platform.bnc.html"
  end
end
