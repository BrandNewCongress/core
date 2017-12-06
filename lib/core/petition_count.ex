defmodule Core.PetitionCount do
  use Agent
  alias Osdi.{Repo, Tagging, Tag}
  import Ecto.Query
  require Logger

  def start_link do
    Task.start_link(&update/0)
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def stats_for(title) do
    Agent.get(__MODULE__, fn state ->
      case Map.get(state, title) do
        nil -> {:error, "not found"}
        vals -> {:ok, vals}
      end
    end)
  end

  def update do
    Logger.info("Updating petition cache")

    petition_tags =
      Repo.all(
        from(
          t in Tag,
          where: ilike(t.name, "%Signed Petition%"),
          select: {t.name, t.id}
        )
      )

    tasks =
      petition_tags
      |> Enum.filter(fn {name, _} -> name |> String.split(":") |> length() < 5 end)
      |> Enum.reduce(%{}, fn {name, tag_id}, acc ->
           petition_name = name |> String.split(":") |> List.last() |> String.trim()

           case Map.get(acc, petition_name) do
             nil -> Map.put(acc, petition_name, [tag_id])
             list -> Map.put(acc, petition_name, [tag_id | list])
           end
         end)
      |> Enum.map(fn {title, tag_ids} ->
           Task.async(fn -> update_petition({title, tag_ids}) end)
         end)

    Enum.each(tasks, fn task -> Task.await(task, 20_000) end)
    Logger.info("Updated petition cache on #{Timex.now() |> DateTime.to_iso8601()}")
  end

  defp update_petition({title, tag_ids}) do
    [total] =
      Repo.all(
        from(
          pt in Tagging,
          where: pt.tag_id in ^tag_ids,
          select: count(pt.id)
        )
      )

    Agent.update(__MODULE__, fn state ->
      Map.put(state, title, %{total: total})
    end)
  end

  def dump_state do
    state = Agent.get(__MODULE__, fn state -> state end)

    state
    |> Enum.map(fn {title, %{total: total}} -> "#{title}:\t#{total}" end)
    |> Enum.join("\n")
  end
end
