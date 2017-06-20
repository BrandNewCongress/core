defmodule Core.ActController do
  use Core.Web, :controller

  def get(conn, params) do
    render conn, "act.html", GlobalOpts.get(conn, params)
  end
end
