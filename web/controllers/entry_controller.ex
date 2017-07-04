defmodule Core.EntryController do
  use Core.Web, :controller

  def get(conn, params) do
    {:ok, campaigns} =
      "candidates"
      |> Cosmic.get_type()
      |> Enum.map(fn
          %{"title" => title, "slug" => slug, "metadata" => %{"district" => district}}
            -> %{"title" => title, "slug" => slug, "district" => district}
        end)
      |> Poison.encode()

    render conn, "entry.html", [title: "Entry", campaigns: campaigns] ++ GlobalOpts.get(conn, params)
  end
end
