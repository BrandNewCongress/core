defmodule Core.PageController do
  use Core.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
