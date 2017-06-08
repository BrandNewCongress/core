defmodule Query do
  def decode(query_string) do
    URI.query_decoder(query_string)
    |> Enum.to_list()
    |> Enum.reduce(%{}, fn({k,v}, acc)-> Map.put(acc, k, v) end)
  end
end
