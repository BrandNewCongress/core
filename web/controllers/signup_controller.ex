defmodule Core.OsdiController do
  use Core.Web, :controller

  def signup(conn, signup_body = %{"person" => %{}}) do
    response =
      signup_body
      |> to_atom_map()
      |> Osdi.PersonSignup.main()
      |> do_remove_tags(signup_body)

    json conn, response
  end

  def record_contact(conn, record_contact_body = %{"contact" => %{}}) do
    as_atom_map = to_atom_map(record_contact_body)
    {:ok, action_date, _} = DateTime.from_iso8601(as_atom_map.action_date)

    response =
      as_atom_map
      |> Map.put(:action_date, action_date)
      |> Osdi.RecordContact.main()

    json conn, Map.take(response, ~w(action_date contact_effort_id contact_type origin_system status_code target_id success identifiers contactor_id)a)
  end

  defp do_remove_tags(person, %{"remove_tags" => tags_to_remove}), do:
    Osdi.Person.remove_tags(person, tags_to_remove)

  defp do_remove_tags(person, %{}), do: person

  defp to_atom_map(map) when is_map(map), do: Map.new(map, fn {k, v} -> {String.to_atom(k), to_atom_map(v)} end)
  defp to_atom_map(v) when is_list(v), do: Enum.map(v, &to_atom_map/1)
  defp to_atom_map(v), do: v
end
