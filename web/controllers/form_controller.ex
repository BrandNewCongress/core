defmodule Core.FormController do
  use Core.Web, :controller

  def get(conn, params = %{"form" => slug, "draft" => draft}) do
    global_opts = GlobalOpts.get(conn, params)

    %{"title" => title, "metadata" => %{
      "share_html" => share_html,
      "brands" => brands
    }} = Cosmic.get(slug)

    if Enum.member? brands, Keyword.get(global_opts, :brand) do
      render conn, "form.html", [share_html: share_html, title: title] ++ global_opts
    else
      redirect_home(conn, params)
    end
  end

  def get(conn, params = %{"form" => slug}) do
    %{"title" => title, "metadata" => %{
      "visibility" => visibility,
      "share_html" => share_html
    }} = Cosmic.get(slug)

    case visibility do
      "Published" -> render conn, "form.html", [share_html: share_html, title: title] ++ GlobalOpts.get(conn, params)
      "Draft" -> redirect_home(conn, params)
    end
  end

  def redirect_home(conn, params) do
    url = case (conn |> GlobalOpts.get(params) |> Keyword.get(:brand)) do
      "jd" -> "https://justicedemocrats.com"
      "bnc" -> "https://brandnewcongress.org"
    end
    redirect(conn, external: url)
  end
end
