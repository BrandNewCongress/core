defmodule Core.StandupChannel do
  use Phoenix.Channel
  require Logger

  def join("standup", _message, socket) do
    {:ok, socket}
  end
end
