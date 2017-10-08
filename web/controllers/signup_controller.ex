defmodule Core.SignupController do
  use Core.Web, :controller

  def simple(conn, signup_body = %{"person" => %{}}) do
    response =
      signup_body
      |> to_atom_map()
      |> Osdi.PersonSignup.main()
      |> do_remove_tags(signup_body)

    json conn, response
  end

  defp do_remove_tags(person, %{"remove_tags" => tags_to_remove}), do:
    Osdi.Person.remove_tags(person, tags_to_remove)

  defp do_remove_tags(person, %{}), do: person

  defp to_atom_map(map) when is_map(map), do: Map.new(map, fn {k, v} -> {String.to_atom(k), to_atom_map(v)} end)
  defp to_atom_map(v) when is_list(v), do: Enum.map(v, &to_atom_map/1)
  defp to_atom_map(v), do: v
end
