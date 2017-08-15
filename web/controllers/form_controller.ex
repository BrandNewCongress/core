defmodule Core.FormController do
  use Core.Web, :controller

  def get(conn, params = %{"form" => slug}) do
    object = %{"metadata" => %{
      "visibility" => visibility
    }} = Cosmic.get(slug)

    case visibility do
      "Draft" -> case params["draft"] do
          true -> render_form(conn, params, object)
          nil -> redirect_home(conn, params)
        end
      "Published" -> render_form(conn, params, object)
    end
  end

  def render_form(conn, params, %{"title" => title, "metadata" =>
      %{"jd_share_html" => jd_share_html,
        "bnc_share_html" => bnc_share_html},
        "slug" => slug}) do

    global_opts = GlobalOpts.get(conn, params)
    brand = Keyword.get(global_opts, :brand)

    brands = get_brands(jd_share_html, bnc_share_html)
    share_html = case brand do
      "jd" -> jd_share_html
      "bnc" -> bnc_share_html
    end

    if Enum.member?(brands, brand) do
      render conn, "form.html",
        [share_html: share_html, title: title, slug: slug, no_footer: true] ++ global_opts
    else
      redirect_home(conn, params)
    end
  end

  defp redirect_home(conn, params) do
    url = case (conn |> GlobalOpts.get(params) |> Keyword.get(:brand)) do
      "jd" -> "https://justicedemocrats.com"
      "bnc" -> "https://brandnewcongress.org"
    end
    redirect(conn, external: url)
  end

  defp get_brands(jd_share_html, bnc_share_html) do
    [jd_share_html, bnc_share_html]
    |> Enum.zip(["jd", "bnc"])
    |> Enum.filter(fn {str, _brand} -> str != "" end)
    |> Enum.map(fn {_str, brand} -> brand end)
  end
end
