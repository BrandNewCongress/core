defmodule Core.ActController do
  use Core.Web, :controller

  def get(conn, params) do
    render conn, "act.html", [title: "Let's get to work",
      header_text: "Let's get to work"] ++ GlobalOpts.get(conn, params)
  end
end
