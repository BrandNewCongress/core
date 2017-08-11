defmodule Nb.Tags do
  import Nb.Api

  def people(tag) do
    get "tags/#{tag}/people"
  end
end
