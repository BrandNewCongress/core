defmodule Core.TypeformController do
  use Core.Web, :controller
  require Logger

  def submit_event(conn, params) do
    response = Typeform.SubmitEvent.on_event_submit(params)
    json conn, %{"ok" => "There you go!"}
  end
end
