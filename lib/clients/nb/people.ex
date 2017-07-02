defmodule Nb.People do
  import Nb.Api

  def push(person) do
    %{body: %{"person" => person}} = put "people/push", [body: %{"person" => person}]
    person
  end

  def update(id, updates) do
    case put "people/#{id}", [body: %{"person" => updates}] do
      %{body: %{"person" => person}} -> person
      some_error -> some_error
    end
  end

  def match(body) do
    case get "people/match", [query: body] do
      %{body: %{"person" => person}} -> person
      _does_not_exist -> {:error, "Does not exist"}
    end
  end

  def add_tags(id, tags) do
    put "people/#{id}/taggings", [body: %{"tagging" => %{"tag" => tags}}]
  end

  def delete_tags(id, tags) do
    delete "people/#{id}/taggings", [body: %{"tagging" => %{"tag" => tags}}]
  end
end
