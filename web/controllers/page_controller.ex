defmodule Core.PageController do
  use Core.Web, :controller

  defp get_platform(brand) do
    %{ "content" => html } = Cosmic.get "#{brand}-platform"
    html
  end

  def index(conn, params) do
    url = case GlobalOpts.get(conn, params) |> Keyword.get("brand") do
      "jd" -> "https://justicedemocrats.com"
      "bnc" -> "https://brandnewcongress.org"
    end

    redirect(conn, to: url)
    # render conn, "index.html", GlobalOpts.get(conn, params)
  end

  def platform(conn, params) do
    opts = GlobalOpts.get(conn, params)
    html = get_platform(Keyword.get(opts, :brand))
    render conn, "platform.html", [html: html] ++ opts
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
end
