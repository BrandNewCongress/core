defmodule Core.ActController do
  use Core.Web, :controller

  def get(conn, params) do
    render conn, "act.html",
      [title: "Let's get to work", header_text: "Let's get to work"] ++ GlobalOpts.get(conn, params)
  end

  def get_candidate(conn, params = %{"candidate" => slug}) do
    {:ok, candidate_json} = Poison.encode(Cosmic.get(slug))

    render conn, "act.html",
      [title: "Let's get to work", header_text: "Let's get to work",
       candidate: candidate_json] ++ GlobalOpts.get(conn, params)
  end
end
