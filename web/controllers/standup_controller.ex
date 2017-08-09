defmodule Core.StandupController do
  use Core.Web, :controller
  plug :put_layout, "minimal.html"

  def get(conn, params) do
    pledges =
      "standup-pledges"
      |> Cosmic.get_type()
      |> Enum.map(&extract_attrs/1)
      |> Enum.sort(&(&1.priority <= &2.priority))

    {:ok, pledges_json} =
      pledges
      |> Poison.encode()

    %{"metadata" => %{"count" => count}} = Cosmic.get("standup-text")

    count = add_comma(count)

    mobile = GlobalOpts.get(conn, params) |> Keyword.get(:mobile)

    if mobile do
      render conn, "standup-mobile.html",
        [pledges: pledges, pledges_json: pledges_json, count: count] ++ GlobalOpts.get(conn, params)
    else
      render conn, "standup-desktop.html",
        [pledges: pledges, pledges_json: pledges_json, count: count] ++ GlobalOpts.get(conn, params)
    end
  end

  defp extract_attrs(
    %{"content" => content, "metadata" =>
      %{"name" => name, "district" => district, "position" => position,
        "youtube_id" => youtube_id, "twitter" => twitter,
        "facebook" => facebook, "instagram" => instagram,
        "priority" => priority, "state" => state,
        "headshot" => %{"imgix_url" => headshot}}}) do

    %{name: name, district: district, position: position,
      youtube_id: youtube_id, content: content, twitter: twitter,
      facebook: facebook, instagram: instagram, headshot: headshot,
      state: state, priority: priority}
  end

  defp add_comma(integer) when is_binary(integer) do
    integer
    |> Integer.parse()
    |> (fn {count, _} -> count end).()
    |> Number.Delimit.number_to_delimited(precision: 0)
  end

  defp add_comma(integer) when is_integer(integer) do
    Number.Delimit.number_to_delimited(integer, precision: 0)
  end
end
