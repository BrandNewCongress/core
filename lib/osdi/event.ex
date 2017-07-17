defmodule Osdi.Event do
  def from_nb(event) do
    event
    |> to_atom_map()
    |> Transformers.Nb.Event.to_map()
  end

  def  convert_to_atom_map(map), do: to_atom_map(map)
  defp to_atom_map(map) when is_map(map), do: Map.new(map, fn {k, v} -> {String.to_atom(k), to_atom_map(v)} end)
  defp to_atom_map(v), do: v
end
