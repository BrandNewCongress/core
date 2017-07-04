defmodule Nb.Events do
  import Nb.Api

  def create(event) do
    case post "sites/brandnewcongress/pages/events", [body: %{"event" => event}] do
      %{body: %{"event" => event}} -> event
      some_error -> some_error
    end
  end

  def stream_all() do
    stream("sites/brandnewcongress/pages/events", [query: %{
      starting: "#{"America/New_York" |> Timex.now() |> Timex.to_date}"
    }])
  end

  def stream_for(%{"candidate" => slug}) do
    %{"metadata" => %{"calendar_id" => calendar_id}} = Cosmic.get(slug)

    stream("sites/brandnewcongress/pages/events", [query: %{
      starting: "#{"America/New_York" |> Timex.now() |> Timex.to_date}",
      calendar_id: calendar_id
    }])
  end
end
