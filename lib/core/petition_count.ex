defmodule Core.PetitionCount do
  use Agent
  alias Osdi.{Repo, Tagging, Tag}
  import Ecto.Query

  @in_last [hours: -1]

  def start_link do
    Task.start_link(&update/0)
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def stats_for(title) do
    Agent.get __MODULE__, fn state ->
      case Map.get(state, title) do
        nil -> {:error, "not found"}
        vals -> {:ok, vals}
      end
    end
  end

  def update do
    petition_tags = Repo.all(from t in Tag,
      where: ilike(t.name, "%Signed Petition%"),
      join: pt in Tagging,
      on: pt.tag_id == t.id,
      select: {t.name, t.id})

    tasks =
      petition_tags
      |> Enum.filter(fn {name, _} -> (name |> String.split(":") |> length()) < 5 end)
      |> Enum.reduce(%{}, fn ({name, tag_id}, acc) ->
        petition_name = name |> String.split(":") |> List.last() |> String.trim()
        case Map.get(acc, petition_name) do
          nil -> Map.put(acc, petition_name, [tag_id])
          list -> Map.put(acc, petition_name, [tag_id | list])
        end
      end)
      # |> Enum.map(fn {title, tag_ids} -> Task.async(fn -> update_petition({title, tag_ids}) end) end)
      |> Enum.map(&update_petition/1)

    Enum.map tasks, &Task.await/1
  end

  defp update_petition({title, tag_ids}) do
    [total] = Repo.all(from pt in Tagging,
      where: pt.tag_id in ^tag_ids,
      select: count(pt.id))

    since = Timex.shift(Timex.now(), @in_last)
    [in_last] = Repo.all(from pt in Tagging,
      where: pt.tag_id in ^tag_ids and
        pt.inserted_at > ^since,
      select: count(pt.id))

    Agent.update __MODULE__, fn state ->
      IO.puts "#{title}: #{total}"
      Map.put(state, title, %{total: total, in_last: in_last})
    end
  end

  def dump_state do
    state = Agent.get __MODULE__, fn state -> state end

    Enum.map state, fn {title, %{total: total, in_last: in_last}} ->
      "#{title}:\t#{total}"
    end
  end
end
