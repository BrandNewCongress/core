defmodule Nb.Events.Rsvps do
  import Nb.Api

  def create(event) do
    case post "sites/brandnewcongress/pages/events", [body: %{"event" => event}] do
      %{body: %{"event" => event}} -> event
      some_error -> some_error
    end
  end
end
