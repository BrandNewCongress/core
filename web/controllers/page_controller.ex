defmodule Core.PageController do
  use Core.Web, :controller

  defp get_platform(brand) do
    %{ "content" => html } = Cosmic.get "#{brand}-platform"
    html
  end

  def index(conn, params) do
    render conn, "index.html", GlobalOpts.get(conn, params)
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

  """
      Tag Manipulation Helpers
  """
  defp is_source_tag(tag) do
    String.split(tag, ":", [global: true])
    |> Enum.map(&(String.trim(&1)))
    |> is_source_tag_list()
  end

  defp is_source_tag_list(["Action" | [ "Joined Website" | _candidate ]]), do: true
  defp is_source_tag_list([_head | [ _head2 | _tail ]]), do: false

  defp extract_candidate(tag) do
    ["Action" | [ _something | candidate ]] = String.split(tag, ":", [global: true])

    candidate
    |> List.to_string
    |> String.trim
  end

  """
      Fetch the user's tags from nation builder to present different unsubscribe
      options
  """
  def unsubscribe_get(conn, params = %{"email" => email}) do
    %{body: {:ok, %{"person" => %{
      "tags" => tags
    }}}} = NB.get "people/match", [query: %{"email" => email}]

    tags = tags
      |> Enum.filter(&(is_source_tag(&1)))
      |> Enum.map(&(extract_candidate(&1)))

    render conn,
      "unsubscribing.html",
      [email: email, tags: tags, no_footer: true] ++ GlobalOpts.get(conn, params)
  end

  """
      Handle the different unsubscribe options, adding tags unsubscribe for those
      sources not present on the request's params
  """
  def unsubscribe_post(conn, params = %{"email" => email}) do
    %{body: {:ok, %{"person" => %{
      "id" => id,
      "tags" => tags
    }}}} = NB.get "people/match", [query: %{"email" => email}]

    to_remove = tags
      |> Enum.filter(&(is_source_tag(&1)))
      |> Enum.map(&(extract_candidate(&1)))
      |> Enum.filter(fn tag -> not Map.has_key?(params, tag) end)

    tags_to_add = to_remove
      |> Enum.map(fn tag -> "Action: Unsubscribed: #{tag}" end)

    IO.inspect(NB.put("people/#{id}/taggings", [body: %{
      "tagging" => tags_to_add
    }]))

    render conn,
      "unsubscribed.html",
      [email: email, no_footer: true, to_remove: to_remove] ++ GlobalOpts.get(conn, params)
  end
end
