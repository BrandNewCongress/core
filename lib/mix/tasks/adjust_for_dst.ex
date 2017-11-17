defmodule Mix.Tasks.AdjustForDst do
  use Mix.Task
  alias Osdi.{Repo, Event}
  import Ecto.Query
  import Ecto.Changeset

  def run(_) do
    upcoming = Repo.all(from e in Event, where: e.start_date > ^Timex.now())
    upcoming = Enum.slice(upcoming, 2..400)

    Enum.each upcoming, fn event = %{start_date: start_date, end_date: end_date} ->
      event
      |> change(start_date: Timex.shift(start_date, hours: 1))
      |> change(end_date: Timex.shift(end_date, hours: 1))
      |> Repo.update!()
    end
  end
end
