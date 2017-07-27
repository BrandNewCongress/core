defmodule Nb.Events.Rsvps do
  import Nb.Api

  def create(event, person) do
    %{"id" => id} = Nb.People.push(person)

    rsvp = %{person_id: id, guests_count: 1, volunteer: false, private: false, canceled: false}

    IO.puts "sites/brandnewcongress/pages/events/#{event}/rsvps"

    case post "sites/brandnewcongress/pages/events/#{event}/rsvps", [body: %{"rsvp" => rsvp}] do
      %{body: %{"rsvp" => rsvp}} -> rsvp
      some_error -> some_error
    end
  end
end
