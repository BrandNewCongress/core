defmodule Core.InfoController do
  use Core.Web, :controller

  def get(conn, params = %{"info" => slug, "draft" => _draft}) do
    global_opts = GlobalOpts.get(conn, params)

    object = %{"title" => title, "content" => content, "metadata" => metadata = %{
      "brands" => brands
    }} = Cosmic.get(slug)

    content_key = "#{Keyword.get(global_opts, :brand)}_content"
    chosen_content =
      if metadata[content_key] && metadata[content_key] != "" do
        metadata[content_key]
      else
        content
      end

    if Enum.member? brands, Keyword.get(global_opts, :brand) do
      render conn, "info.html",
        [content: chosen_content, title: title] ++ global_opts ++ empty_params(object)
    else
      redirect_home(conn, params)
    end
  end

  def get(conn, params = %{"info" => slug}) do
    global_opts = GlobalOpts.get(conn, params)

    object = %{"title" => title, "content" => content, "metadata" => metadata = %{
      "visibility" => visibility,
      "brands" => brands
    }} = Cosmic.get(slug)

    content_key = "#{Keyword.get(global_opts, :brand)}_content"
    chosen_content =
      if metadata[content_key] && metadata[content_key] != "" do
        metadata[content_key]
      else
        content
      end

    if Enum.member? brands, Keyword.get(global_opts, :brand) do
      case visibility do
        "Draft" -> redirect_home(conn, params)
        "Published" ->
          render conn, "info.html",
            [content: chosen_content, title: title] ++ global_opts ++ empty_params(object)
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
