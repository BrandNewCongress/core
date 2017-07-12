defmodule Core.EntryController do
  use Core.Web, :controller

  def get(conn, params) do
    candidates =
      "candidates"
      |> Cosmic.get_type()
      |> Enum.map(fn
          %{"title" => title, "slug" => slug, "metadata" => %{"district" => district}}
            -> %{"title" => title, "slug" => slug, "district" => district}
        end)

    other = [%{"title" => "Justice Democrats", "slug" => "justicedemocrats", "district" => nil},
             %{"title" => "Brand New Congress", "slug" => "brandnewcongress", "district" => nil}]

    {:ok, campaigns} = Poison.encode(candidates ++ other)

    render conn, "entry.html", [title: "Entry", campaigns: campaigns] ++ GlobalOpts.get(conn, params)
  end
end
