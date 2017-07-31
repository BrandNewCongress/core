defmodule Core.JotformController do
  use Core.Web, :controller
  require Logger

  def submit_event(conn, params) do
    # try do
      response = Jotform.SubmitEvent.on_event_submit(params)
      json conn, response
    # rescue
    #   _e ->
    #     Core.Mailer.typeform_failure_alert(params)
    #     json conn, %{"ok" => "But error"}
    # end
  end
end
