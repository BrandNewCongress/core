defmodule Mix.Tasks.RemoveNbEventAutoReponders do
  use Mix.Task

  def run(_) do
    Nb.Events.stream_all()
    |> Stream.filter(&has_autoresponder/1)
    |> Stream.map(&remove_autoresponder/1)
    |> Stream.map(&write/1)
    |> Enum.to_list()
    |> length()
  end

  defp has_autoresponder(%{"autoresponse" => %{"broadcaster_id" => broadcaster_id, "subject" => subject, "body" => body}}) do
    broadcaster_id != nil and subject != nil and body != nil
  end

  defp has_autoresponder(_) do
    false
  end

  defp remove_autoresponder(event) do
    Map.put(event, "autoresponse", %{"broadcaster_id" => nil, "subject" => nil, "body" => nil})
  end

  defp write(new_event = %{"id" => id}) do
    Nb.Events.update(id, new_event)
  end
end
