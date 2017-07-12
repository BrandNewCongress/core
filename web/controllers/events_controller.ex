defmodule Core.EventsController do
  use Core.Web, :controller

  def get(conn, params) do
    district =
      (params["district"] || conn.cookies["district"])
      |> String.upcase()
      |> District.normalize()

    {:ok, coordinates} =
      district
      |> District.centroid()
      |> Tuple.to_list()
      |> Poison.encode()

    render conn, "events.html",
      [district: district, coordinates: coordinates, title: "Events"] ++ GlobalOpts.get(conn, params)
  end

end
