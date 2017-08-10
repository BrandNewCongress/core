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

    %{"metadata" =>
      %{"count" => count, "primary_video_id" => primary_video_id,
        "secondary_video_id" => secondary_video_id}} = Cosmic.get("standup-text")

    template =
      if conn |> GlobalOpts.get(params) |> Keyword.get(:mobile) do
        "standup-mobile.html"
      else
         "standup-desktop.html"
      end

    render conn, template,
      [count: add_comma(count), pledges: pledges, pledges_json: pledges_json,
       primary_video_id: primary_video_id, secondary_video_id: secondary_video_id,
       title: "Medicare for All"]
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
