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

    cosponsors =
      "standup-endorsements"
      |> Cosmic.get_type()
      |> Enum.map(&extract_endorsement_attrs/1)

    %{"metadata" =>
      %{"count" => count, "primary_video_id" => primary_video_id,
        "secondary_video_id" => secondary_video_id,
        "box_1_header" => box_1_header, "box_1_text" => box_1_text,
        "box_2_header" => box_2_header, "box_2_text" => box_2_text,
        "circle_1_header" => circle_1_header, "circle_1_text" => circle_1_text,
        "circle_2_header" => circle_2_header, "circle_2_text" => circle_2_text,
        "circle_3_header" => circle_3_header, "circle_3_text" => circle_3_text,
        "circle_4_header" => circle_4_header, "circle_4_text" => circle_4_text}} = Cosmic.get("standup-text")

    template =
      if conn |> GlobalOpts.get(params) |> Keyword.get(:mobile) do
        "standup-mobile.html"
      else
         "standup-desktop.html"
      end

    assigns =
      [count: add_comma(count), pledges: pledges, pledges_json: pledges_json,
       primary_video_id: primary_video_id, secondary_video_id: secondary_video_id,
       box_1_header: box_1_header, box_1_text: box_1_text,
       box_2_header: box_2_header, box_2_text: box_2_text,
       circle_1_header: circle_1_header, circle_1_text: circle_1_text,
       circle_2_header: circle_2_header, circle_2_text: circle_2_text,
       circle_3_header: circle_3_header, circle_3_text: circle_3_text,
       circle_4_header: circle_4_header, circle_4_text: circle_4_text,
       cosponsors: cosponsors, title: "Medicare for All"]

    render conn, template, assigns
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

  defp extract_endorsement_attrs(%{"metadata" => %{"name" => name, "url" => url, "logo" => %{"imgix_url" => logo}}}) do
    %{name: name, url: url, logo: logo}
  end
end
