defmodule Core.InfoController do
  use Core.Web, :controller

  def get(conn, params = %{"info" => slug, "draft" => _draft}) do
    global_opts = GlobalOpts.get(conn, params)

    object = %{"title" => title, "content" => content, "metadata" => %{
      "brands" => brands
    }} = Cosmic.get(slug)

    if Enum.member? brands, Keyword.get(global_opts, :brand) do
      render conn, "info.html", [content: content, title: title] ++ global_opts ++ empty_params(object)
    else
      redirect_home(conn, params)
    end
  end

  def get(conn, params = %{"info" => slug}) do
    global_opts = GlobalOpts.get(conn, params)

    object = %{"title" => title, "content" => content, "metadata" => %{
      "visibility" => visibility,
      "brands" => brands
    }} = Cosmic.get(slug)

    if Enum.member? brands, Keyword.get(global_opts, :brand) do
      case visibility do
        "Published" -> render conn, "info.html", [content: content, title: title] ++ GlobalOpts.get(conn, params) ++ empty_params(object)
        "Draft" -> redirect_home(conn, params)
      end
    else
      redirect_home(conn, params)
    end
  end

  def redirect_home(conn, params) do
    url = case (conn |> GlobalOpts.get(params) |> Keyword.get(:brand)) do
      "jd" -> "https://justicedemocrats.com"
      "bnc" -> "https://brandnewcongress.org"
    end
    redirect(conn, external: url)
  end

  defp empty_params(%{"metadata" => %{"empty" => "Empty"}}), do: [no_header: true, no_footer: true]
  defp empty_params(_else), do: []
end
