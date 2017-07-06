defmodule Core.ActController do
  use Core.Web, :controller

  def get(conn, params) do
    district = params["district"]

    render conn, "act.html",
      [title: "Act", district: district, district_error: nil,
       event_action_options: event_action_options(conn, params),
       home_action_options: home_action_options(conn, params)] ++ GlobalOpts.get(conn, params)
  end

  def district(conn, params = %{"district" => district}) do
    # {district, district_error} = District.get(district) do

    render conn, "act.html",
      [title: "Act", district: district, district_error: nil,
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
    [%{icon: "event.html", label: "Attend an Event", href: "https://events.brandnewcongress.org"},
     %{icon: "host.html", label: "Host an Event", href: "/form/submit-event"}]
  end

  defp home_action_options(conn, params) do
    # TODO - route to call candidate near them
    [%{icon: "call.html", label: "Call Voters", href: "/act/call"},
     %{icon: "nominate.html", label: "Nominate a Candidate", href: "https://brandnewcongress.org/nominate"},
     %{icon: "district.html", label: "Tell Us About Your District", href: "https://docs.google.com/forms/d/e/1FAIpQLSe8CfK0gUULEVpYFm9Eb4iyGOL-_iDl395qB0z4hny7ek4iNw/viewform?refcode=www.google.com"},
     %{icon: "team.html", label: "Join a National Team", href: "/form/teams"}]
  end
end
