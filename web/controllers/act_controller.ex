defmodule Core.ActController do
  use Core.Web, :controller

  def get(conn, params) do
    district = params["district"]

    IO.inspect GlobalOpts.get(conn, params)

    render conn, "act.html",
      [title: "Act", district: district,
       event_action_options: event_action_options(conn, params),
       home_action_options: home_action_options(conn, params)] ++ GlobalOpts.get(conn, params)
  end

  def get_candidate(conn, params = %{"candidate" => slug}) do
    candidate = Cosmic.get(slug)
    candidate = put_in(candidate["metadata"]["calling_prompt"], "")
    candidate = put_in(candidate["metafields"], %{})

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
          %{"metadata" => %{"callable" => "Callable"}} -> true
          _ -> false
        end)
      |> Enum.map(fn %{"slug" => slug, "title" => name} -> %{slug: slug, name: name} end)
      |> Poison.encode()

    callable_candidates
  end

  def candidate_calling_html(conn, %{"candidate" => slug}) do
    candidate = Cosmic.get(slug)
    text conn, candidate["metadata"]["calling_prompt"]
  end

  defp event_action_options(conn, params) do
    [%{icon: "placeholder.svg", label: "Attend an Event", href: "https://events.brandnewcongress.org"},
     %{icon: "placeholder.svg", label: "Host an Event", href: "/submit-event"}]
  end

  defp home_action_options(conn, params) do
    # TODO - route to call candidate near them
    [%{icon: "placeholder.svg", label: "Call Voters", href: "/act/call"},
     %{icon: "placeholder.svg", label: "Nominate a Candidate", href: "https://brandnewcongress.org/nominate"},
     %{icon: "placeholder.svg", label: "Tell Us About Your District", href: "https://docs.google.com/forms/d/e/1FAIpQLSe8CfK0gUULEVpYFm9Eb4iyGOL-_iDl395qB0z4hny7ek4iNw/viewform?refcode=www.google.com"},
     %{icon: "placeholder.svg", label: "Join a National Team", href: "/form/teams"}]
  end
end
