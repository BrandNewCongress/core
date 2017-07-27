defmodule Jotform.SubmitEvent do
  require Logger

  @doc"""
  Takes a typeform post body from a webhook, creates the event in NB, and sends an email
  """
  def on_event_submit(data) do
    IO.inspect data
    %{"ok" => "There you go!"}
  end
end
