defmodule Core.LeaderboardReportChannel do
  use Phoenix.Channel
  require Logger

  def join("leaderboard-report", _message, socket) do
    {:ok, socket}
  end

  def handle_in("download", _message, socket) do
    l =
      Core.LeaderboardHelpers.report_stream()
      |> Stream.map(&push_row(socket, &1))
      |> Enum.to_list()

    push(socket, "done", %{"length" => l})

    {:noreply, socket}
  end

  defp push_row(socket, {
         count,
         ref,
         %{"first_name" => first, "last_name" => last, "email" => email, "phone" => phone}
       }) do
    push(socket, "row", %{
      "count" => count,
      "row" => "#{ref}, #{count}, #{first}, #{last}, #{email}, #{phone}"
    })
  end
end
