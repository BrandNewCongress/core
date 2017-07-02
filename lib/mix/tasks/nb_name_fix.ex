defmodule Mix.Tasks.NbNameFix do
  use Mix.Task

  def run(_) do
    "lists/1794/people"
    |> Nb.Api.stream()
    |> Enum.map(fn %{"id" => id, "last_name" => last_name} ->

      ln = last_name
      |> String.replace("[", "")
      |> String.replace("]", "")
      |> String.replace("\"", "")

      Nb.People.update(id, %{"last_name" => ln})
    end)
  end
end

# Mix.Tasks.NbNameFix.run("hi")
