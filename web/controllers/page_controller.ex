  defmodule Core.PageController do
  use Core.Web, :controller

  def index(conn, params) do
    url = case conn |> GlobalOpts.get(params) |> Keyword.get(:brand) do
      "jd" -> "https://justicedemocrats.com"
      "bnc" -> "https://brandnewcongress.org"
    end

    redirect(conn, external: url)
    # render conn, "index.html", GlobalOpts.get(conn, params)
  end

  def platform(conn, params) do
    opts = GlobalOpts.get(conn, params)
    brand = Keyword.get(opts, :brand)

    areas =
      "platform-areas"
      |> Cosmic.get_type()
      |> Enum.filter(&(by_brand(&1, brand)))
      |> Enum.map(&normalize_area/1)

    render conn, "platform.html", [title: "Platform", areas: areas] ++ opts
  end

  def candidates(conn, params) do
    render conn, "candidates.html", GlobalOpts.get(conn, params)
  end

  def candidate(conn, params = %{"candidate" => candidate}) do
    case Cosmic.get candidate do
      %{body: {:ok, _}} ->
        render conn, "candidate-page-404.html", [candidate: candidate] ++ GlobalOpts.get(conn, params)
      metadata ->
        render conn, "candidate-page.html", [metadata: metadata] ++ GlobalOpts.get(conn, params)
    end
  end

  defp normalize_area(%{"title" => title, "metadata" => %{"introduction" => introduction, "planks" => planks}}) do
    %{title: title, introduction: introduction, planks: planks}
  end

  defp by_brand(%{"metadata" => %{"brands" => brands}}, brand), do: Enum.member?(brands, brand)
end
