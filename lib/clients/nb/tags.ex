defmodule Nb.Tags do
  import Nb.Api

  def people(tag) do
    get "tags/#{URI.encode(tag)}/people"
  end

  def stream_people(tag) do
    stream "tags/#{URI.encode(tag)}/people"
  end
end
