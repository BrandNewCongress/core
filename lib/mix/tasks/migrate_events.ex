defmodule MigrateEvents do
  alias Osdi.{Repo, Event}

  def go do
    all_events =
      Repo.all(Event)
      |> Repo.preload([:tags, :location])
      |> Enum.map(fn event ->
        names_only = Enum.map(event.tags, fn %{name: name} -> name end)

        event
        |> Map.put(:tags, names_only)
        |> Map.drop([:creator, :organizer, :modified_by])
      end)

    all_events
    |> Enum.slice(12 + 130 + 31 + 3, 500)
    |> Enum.each(fn event ->
      result = EventProxy.post("events", body: event)
      case result do
        %HTTPotion.ErrorResponse{} -> IO.puts "Error on #{event.id}"
        _ -> IO.puts "Success for #{event.id}"
      end
      :timer.sleep(1000)
    end)
  end
end
