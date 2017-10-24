defmodule Core.JotformController do
  use Core.Web, :controller
  require Logger

  def submit_event(conn, params) do
    %{"metadata" => %{"event_submitted" => success_hook, "submission_failure" => failure_hook}} =
      Cosmic.get("event-webhooks")

    try do
      response = Jotform.SubmitEvent.on_event_submit(params)

      success_hook
      |> HTTPotion.post(body: response |> Poison.encode!())
      |> inspect()
      |> Logger.info()

      json(conn, response)
    rescue
      _e ->
        Core.EventMailer.failure_alert(params)

        failure_hook
        |> HTTPotion.post(body: params |> Poison.encode!())
        |> inspect()
        |> Logger.info()

        json(conn, %{"ok" => "But error"})
    end
  end
end
