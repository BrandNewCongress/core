defmodule Core.LeaderboardReportChannel do
  use Phoenix.Channel
  require Logger

  def join("leaderboard-report", _message, socket) do
    {:ok, socket}
  end

  def handle_in("download", _message, socket) do
    tags =
      "tags"
      |> Nb.Api.stream()
      |> Stream.filter(&is_ref_tag/1)
      |> Stream.map(&get_person_of_tag/1)
      |> Stream.map(&get_signed_up_count/1)
      |> Stream.map(&(push_row(socket, &1)))
      |> Enum.to_list()

    push socket, "done", %{}

    {:noreply, socket}
  end

  defp is_ref_tag(%{"name" => "Recruiter Code:" <> _}), do: true
  defp is_ref_tag(_tag), do: false

  defp get_person_of_tag(%{"name" => tag}) do
    person =
      tag
      |> Nb.Tags.stream_people()
      |> Enum.take(1)
      |> List.first()

    {tag, person}
  end

  defp get_signed_up_count({tag, person}) do
    ref =
      tag
      |> String.split(":")
      |> List.last()
      |> String.trim()

    count =
      "Action: Joined Website: Brand New Congress: #{ref}"
      |> Nb.Tags.stream_people()
      |> Enum.to_list()
      |> length()

    {count, person}
  end

  defp push_row(socket, {count,
      %{"first_name" => first, "last_name" => last, "email" => email,
        "phone" => phone}}) do

    push socket, "row", %{"count" => count, "row" => "#{count}, #{first}, #{last}, #{email}, #{phone}"}
  end
end
