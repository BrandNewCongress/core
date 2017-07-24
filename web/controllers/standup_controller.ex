defmodule Core.StandupController do
  use Core.Web, :controller
  plug :put_layout, "minimal.html"

  def get(conn, params) do
    render conn, "standup.html", GlobalOpts.get(conn, params)
  end
end
