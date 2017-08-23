defmodule LiveVox.SessionAgent do
  use Agent

  def start_link do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def get_token do
    Agent.get(__MODULE__, fn token -> token end)
  end

  def set_token(token) do
    Agent.update(__MODULE__, fn _ -> token end)

    Task.async(fn ->
      :timer.sleep(54_000_000)
      Agent.update(__MODULE__, fn _ -> nil end)
    end)
  end
end
