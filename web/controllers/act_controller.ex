defmodule Core.ActController do
  use Core.Web, :controller

  def get(conn, params) do
    render conn, "act.html",
      [title: "Let's get to work", header_text: "Let's get to work"] ++ GlobalOpts.get(conn, params)
  end

  def get_candidate(conn, params = %{"candidate" => slug}) do
    {:ok, candidate_json} = Poison.encode(Cosmic.get(slug))
    {:ok, metadata_json} = Poison.encode(Cosmic.get("act-page"))

    render conn, "act.html",
      [title: "Let's get to work", header_text: "Let's get to work",
       candidate: candidate_json, metadata: metadata_json] ++ GlobalOpts.get(conn, params)
  end
end
