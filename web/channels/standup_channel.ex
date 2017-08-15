defmodule Core.StandupChannel do
  use Phoenix.Channel
  require Logger

  # require Core.StandUpVideo

  def join("standup", _message, socket) do
    {:ok, socket}
  end

  def handle_in("congress", _content, socket) do
    push socket, "congress", %{congress: Congress.reps_by_state()}
    {:noreply, socket}
  end
end
