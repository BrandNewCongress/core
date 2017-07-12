defmodule Nb.Contacts do
  import Nb.Api

  def create(person_id, contact) do
    case post "people/#{person_id}/contacts", [body: %{"contact" => contact}] do
      %{body: %{"contact" => contact}} -> contact
      some_error -> some_error
    end
  end

  def list(person_id) do
    get "contacts", [query: %{"person_id" => person_id}]
  end
end
