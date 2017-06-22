defmodule Core.ActChannel do
  use Phoenix.Channel

  def join("act", _message, socket) do
    {:ok, socket}
  end

  def handle_in("zip", %{"zip" => zip}, socket) do
    case Zip.closest_candidate(zip) do
      candidate = %{"metadata" => %{"zip" => candidate_zip}} ->
        push socket, "candidate", %{"candidate" => candidate}
        push socket, "center", %{"center" => Zip.coords_of(candidate_zip)}
      nil ->
        push socket, "candidate", %{"candidate" => nil}
    end

    {:noreply, socket}
  end
end
