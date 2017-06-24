defmodule Core.ActController do
  use Core.Web, :controller

  def get(conn, params) do
    render conn, "act.html",
      [title: "Let's get to work", header_text: "Let's get to work", candidate: "{}",
       callable: callable_json(), initial_selected: "attend-event"] ++ GlobalOpts.get(conn, params)
  end

  def get_candidate(conn, params = %{"candidate" => slug}) do
    candidate = Cosmic.get(slug)
    {:ok, candidate_json} = Poison.encode(candidate)

    render conn, "act.html",
      [title: "Let's get to work", header_text: "Let's get to work",
       candidate: candidate_json, callable: callable_json(),
       initial_selected: Map.get(params, "selected", "attend-event")] ++ GlobalOpts.get(conn, params)
  end

  defp callable_json do
    {:ok, callable_candidates} =
      "candidates"
      |> Cosmic.get_type()
      |> Enum.filter(fn
          %{"metadata" => %{"callable" => callables}} -> length(callables) > 0
          _ -> false
        end)
      |> Enum.map(fn %{"slug" => slug, "title" => name} -> %{slug: slug, name: name} end)
      |> Poison.encode()

    callable_candidates
  end
end
