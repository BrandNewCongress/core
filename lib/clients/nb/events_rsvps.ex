defmodule Nb.Events.Rsvps do
  import Nb.Api

  def create(event, person) do
    %{"id" => id} =
      person
      |> Map.take(["email", "first_name", "last_name", "phone"])
      |> Nb.People.push()

    %{"primary_address" => address} = person
    Nb.People.update(id, %{"primary_address" => address})

    rsvp = %{person_id: id, guests_count: 1, volunteer: false, private: false, canceled: false}

    case post "sites/brandnewcongress/pages/events/#{event}/rsvps", [body: %{"rsvp" => rsvp}] do
      %{body: %{"rsvp" => rsvp}} -> rsvp
      some_error -> some_error
    end
  end
end
