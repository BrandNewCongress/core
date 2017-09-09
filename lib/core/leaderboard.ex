defmodule Core.LeaderboardHelpers do
  require Logger

  def report_stream do
    "tags"
    |> Nb.Api.stream()
    |> Stream.filter(&is_ref_tag/1)
    |> Stream.map(&get_person_of_tag/1)
    |> Stream.map(&get_signed_up_count/1)
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

    count = try do
      "Action: Joined Website: Brand New Congress: #{ref}"
      |> Nb.Tags.stream_people()
      |> Enum.to_list()
      |> length()
    rescue
      _e -> 0
    end

    {count, ref, person}
  end
end
