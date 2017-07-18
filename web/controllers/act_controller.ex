defmodule Core.ActController do
  use Core.Web, :controller

  def get(conn, params) do
    district = extract_district(conn, params)
    render_act(conn, params, district)
  end

  def post(conn, params = %{"district" => district}) do
    {district, {x, y}} = District.from_unknown(district)
    {:ok, json_coordinates} = Poison.encode([y, x])

    conn
    |> put_resp_cookie("district", district, [http_only: false])
    |> put_resp_cookie("coordinates", json_coordinates, [http_only: false])
    |> render_act(params, district)
  end

  def get_call(conn, params) do
    district = extract_district(conn, params)
    render_call(conn, params, district)
  end

  def get_candidate_call(conn, params = %{"candidate" => candidate}) do
    %{"metadata" => %{"district" => district}} = Cosmic.get(candidate)
    render_call(conn, params, district)
  end

  defp render_act(conn, params, district) do
    %{candidate: candidate, closest_candidate: closest_candidate}
      = candidate_options(district)

    render conn, "act.html",
      [title: "Act", district: district, candidate: candidate,
       closest_candidate: closest_candidate,
       event_action_options: event_action_options(conn, params),
       home_action_options: home_action_options(conn, params)] ++ GlobalOpts.get(conn, params)
  end

  defp render_call(conn, params, district) do
    %{candidate: candidate, closest_candidate: closest_candidate}
      = candidate_options(district)

    candidate_calling_page = cond do
      candidate != nil -> candidate["metadata"]["calling_prompt"]
      closest_candidate != nil -> closest_candidate["metadata"]["calling_prompt"]
      true -> ""
    end

    callable_maps = callable_candidates()
    callable_slugs = Enum.map(callable_maps, fn %{slug: slug} -> slug end)

    draft = Map.has_key?(params, "draft")

    render conn, "call.html",
      [title: "Call Voters", district: district, candidate: candidate,
       on_hours: on_hours?(candidate), closest_candidate: closest_candidate,
       calling_script_link: candidate["metadata"]["calling_script_link"],
       candidate_calling_page: candidate_calling_page,
       callable_candidates: callable_maps, callable_slugs: callable_slugs,
       event_action_options: event_action_options(conn, params),
       home_action_options: home_action_options(conn, params),
       draft: draft] ++ GlobalOpts.get(conn, params)
  end

  def legacy_redirect(conn, _params = %{"candidate" => candidate, "selected" => _selected}) do
    %{"metadata" => %{"district" => district}} = Cosmic.get(candidate)
    conn
    |> put_resp_cookie("district", district, [http_only: false])
    |> redirect(to: "/act/call")
  end

  def legacy_redirect(conn, _params = %{"candidate" => candidate}) do
    %{"metadata" => %{"district" => district}} = Cosmic.get(candidate)

    conn
    |> put_resp_cookie("district", district, [http_only: false])
    |> redirect(to: "/act")
  end

  defp event_action_options(_conn, _params) do
    [%{icon: "event.html", label: "Attend an Event", href: "https://events.brandnewcongress.org"},
     %{icon: "host.html", label: "Host an Event", href: "/form/submit-event"}]
  end

  defp home_action_options(_conn, _params) do
    [%{icon: "call-icon.html", label: "Call Voters", href: "/act/call"},
     %{icon: "nominate-icon.html", label: "Nominate a Candidate", href: "https://brandnewcongress.org/nominate"},
     %{icon: "district-icon.html", label: "Tell Us About Your District", href: "https://docs.google.com/forms/d/e/1FAIpQLSe8CfK0gUULEVpYFm9Eb4iyGOL-_iDl395qB0z4hny7ek4iNw/viewform?refcode=www.google.com"},
     %{icon: "team-icon.html", label: "Join a National Team", href: "/form/teams"}]
  end

  defp candidate_options(district) do
    candidate = if district, do: District.get_candidate(district), else: nil
    closest_candidate =
      if district != nil and candidate == nil do
        District.closest_candidate(district)
      else
        nil
      end

    %{candidate: candidate, closest_candidate: closest_candidate}
  end

  defp extract_district(conn, params) do
    district = params["district"] || conn.cookies["district"]
    district = if district == "clear", do: nil, else: district
    district
  end

  defp on_hours?(%{"metadata" => %{"time_zone" => time_zone}}) do
    now = time_zone |> Timex.now()
    local_hours = now.hour
    weekday = Timex.weekday(now)

    case weekday do
      n when n in [5, 6] -> local_hours >= 10 and local_hours < 21
      _n -> local_hours >= 17 and local_hours < 21
    end
  end

  defp on_hours?(_else) do
    false
  end

  defp callable_candidates do
    "candidates"
    |> Cosmic.get_type()
    |> Enum.filter(&(is_callable(&1)))
    |> Enum.map(fn %{"slug" => slug, "title" => name} -> %{slug: slug, name: name} end)
  end

  defp is_callable(%{"metadata" => %{"callable" => "Callable", "time_zone" => time_zone}}) do
    now = time_zone |> Timex.now()
    local_hours = now.hour
    weekday = Timex.weekday(now)

    case weekday do
      n when n in [5, 6] -> local_hours >= 10 and local_hours < 21
      _n -> local_hours >= 17 and local_hours < 21
    end
  end

  defp is_callable(_else) do
    false
  end
end
