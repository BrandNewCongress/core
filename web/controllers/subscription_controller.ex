defmodule Core.SubscriptionController do
  use Core.Web, :controller

  @doc"""
  Tag Manipulation Helpers
  """
  defp is_source_tag(tag) do
    String.split(tag, ":", [global: true])
    |> Enum.map(&(String.trim(&1)))
    |> is_source_tag_list()
  end

  defp is_unsubscribe_tag(tag) do
    String.split(tag, ":", [global: true])
    |> Enum.map(&(String.trim(&1)))
    |> is_unsubscribed_tag_list()
  end

  defp is_source_tag_list(["Action" | [ "Joined Website" | _ ]]), do: true
  defp is_source_tag_list(_), do: false
  defp is_unsubscribed_tag_list(["Action" | [ "Unsubscribed" | _ ]]), do: true
  defp is_unsubscribed_tag_list(_), do: false

  defp extract_candidate(tag) do
    ["Action" | [ _ | candidate ]] = String.split(tag, ":", [global: true])

    candidate
    |> List.to_string
    |> String.trim
  end

  @doc"""
  Fetch the user's tags from nation builder to present different unsubscribe options
  """
  def unsubscribe_get(conn, params = %{"email" => email}) do
    %{body: {:ok, %{"person" => %{
      "tags" => tags
    }}}} = NB.get "people/match", [query: %{"email" => email}]

    unsubscribed_tags = tags
      |> Enum.filter(&(is_unsubscribe_tag(&1)))
      |> Enum.map(&(extract_candidate(&1)))

    subscribed_tags = tags
      |> Enum.filter(&(is_source_tag(&1)))
      |> Enum.map(&(extract_candidate(&1)))

    subscriptions = subscribed_tags
      |> Enum.map(fn tag -> {tag, not Enum.member?(unsubscribed_tags, tag)} end)

    render conn,
      "unsubscribing.html",
      [
        email: email, subscriptions: subscriptions, no_footer: true,
        title: "Unsubscribe"
      ] ++ GlobalOpts.get(conn, params)
  end

  @doc"""
  Handle the different unsubscribe options, adding tags unsubscribe for those
  sources not present on the request's params
  """
  def unsubscribe_post(conn, params = %{"email" => email}) do
    %{body: {:ok, %{"person" => %{
      "id" => id,
      "tags" => tags
    }}}} = NB.get "people/match", [query: %{"email" => email}]

    current_sources = tags
      |> Enum.filter(&(is_source_tag(&1)))
      |> Enum.map(&(extract_candidate(&1)))

    # Add unsubscription tags
    unsubscribe_task = Task.async(fn ->
      to_unsub = current_sources
        |> Enum.filter(fn tag -> not Map.has_key?(params, tag) end)

      tags_to_add = to_unsub
        |> Enum.map(fn tag -> "Action: Unsubscribed: #{tag}" end)

      {:ok, put_body_string} = Poison.encode(%{"tagging" => %{
        "tag": tags_to_add
      }})

      NB.put("people/#{id}/taggings", [body: put_body_string])

      to_unsub
    end)

    # Remove no longer wanted unsubscription tags
    subscribe_task = Task.async(fn ->
      unsubs_to_remove = tags
        |> Enum.filter(&(is_unsubscribe_tag(&1)))
        |> Enum.map(&(extract_candidate(&1)))
        |> Enum.filter(fn tag -> Map.has_key?(params, tag) end)

      tags_to_remove = unsubs_to_remove
        |> Enum.map(fn tag -> "Action: Unsubscribed: #{tag}" end)

      {:ok, put_body_string} = Poison.encode(%{"tagging" => %{
        "tag": tags_to_remove
      }})

      NB.delete("people/#{id}/taggings", [body: put_body_string])

      unsubs_to_remove
    end)

    to_unsubscribe = Task.await(unsubscribe_task)
    to_subscribe = Task.await(subscribe_task)

    render conn,
      "unsubscribed.html",
      [
        email: email, no_footer: true, to_unsubscribe: to_unsubscribe,
        to_subscribe: to_subscribe, title: "Unsubscribe"
      ] ++ GlobalOpts.get(conn, params)
  end
end
