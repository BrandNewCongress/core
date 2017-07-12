defmodule Core.EventsController do
  use Core.Web, :controller

  def get(conn, params) do
    district = params["district"] || conn.cookies["district"]
    render conn, "events.html", [district: district] ++ GlobalOpts.get(conn, params)
  end

end
