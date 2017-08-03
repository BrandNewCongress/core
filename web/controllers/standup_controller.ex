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

    render conn, "standup.html",
      [pledges: pledges, pledges_json: pledges_json] ++ GlobalOpts.get(conn, params)
  end

  defp extract_attrs(
    %{"content" => content, "metadata" =>
      %{"name" => name, "district" => district, "position" => position,
        "youtube_url" => youtube_url, "twitter" => twitter,
        "facebook" => facebook, "instagram" => instagram,
        "priority" => priority, "state" => state,
        "headshot" => %{"imgix_url" => headshot}}}) do

    %{name: name, district: district, position: position,
      youtube_url: youtube_url, content: content, twitter: twitter,
      facebook: facebook, instagram: instagram, headshot: headshot,
      state: state, priority: priority}
  end
end
