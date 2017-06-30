defmodule Core.EntryController do
  use Core.Web, :controller

  def get(conn, params) do
    {:ok, campaigns} =
      "candidates"
      |> Cosmic.get_type()
      |> Enum.map(&(Map.take(&1, ["title", "slug"])))
      |> Poison.encode()

    render conn, "entry.html", [campaigns: campaigns] ++ GlobalOpts.get(conn, params)
  end
end
