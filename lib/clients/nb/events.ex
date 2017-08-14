defmodule Nb.Events do
  import Nb.Api

  def create(event) do
    case post "sites/brandnewcongress/pages/events", [body: %{"event" => event}] do
      %{body: %{"event" => event}} -> event
      some_error -> some_error
    end
  end

  def update(id, event) do
    case put "sites/brandnewcongress/pages/events/#{id}", [body: %{"event" => event}] do
      %{body: %{"event" => event}} -> event
      some_error -> some_error
    end
  end

  def stream_all() do
    "sites/brandnewcongress/pages/events"
    |> stream([query: %{starting: "#{"America/New_York" |> Timex.now() |> Timex.to_date}"}])
    |> Enum.filter(&(is_published(&1)))
  end

  def stream_for(%{"candidate" => slug}) do
    %{"metadata" => %{"calendar_id" => calendar_id}} = Cosmic.get(slug)

    "sites/brandnewcongress/pages/events"
    |> stream([query:
        %{starting: "#{"America/New_York" |> Timex.now() |> Timex.to_date}",
          calendar_id: calendar_id}])
    |> Enum.filter(&(is_published(&1)))
  end

  defp is_published(%{"venue" => %{"address" => %{"address1" => _something}}}), do: true
  defp is_published(_else), do: false
end
