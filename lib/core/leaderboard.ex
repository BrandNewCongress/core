defmodule Core.LeaderboardHelpers do
  require Logger
  import Ecto.Query
  alias Osdi.{Repo, Tag, Tagging}

  def report_stream do
    Tag
    |> Repo.all()
    |> Stream.filter(&is_ref_tag/1)
    |> Stream.map(&get_person_of_tag/1)
    |> Stream.map(&get_signed_up_count/1)
  end

  defp is_ref_tag(%{name: "Recruiter Code:" <> _}), do: true
  defp is_ref_tag(_tag), do: false

  defp get_person_of_tag(tag) do
    preloaded = Repo.preload(tag, [:people])
    person = preloaded.people |> List.first()

    {tag, person}
  end

  defp get_signed_up_count({tag, person}) do
    ref =
      tag.name
      |> String.split(":")
      |> List.last()
      |> String.trim()

    ref_tag_name = "Action: Joined Website: Brand New Congress: #{ref}"
    signup_count = Repo.all(from t in Tagging, where: t.tag_id == ^tag.id) |> length()

    {signup_count, ref, person}
  end
end
