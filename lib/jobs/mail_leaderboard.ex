defmodule Core.Jobs.MailLeaderboard do
  def send do
    Core.LeaderboardHelpers.report_stream()
    |> Stream.map(&format_row/1)
    |> Stream.map(&Core.LeaderboardMailer.send_leaderboard/1)
    |> Enum.to_list()
  end

  defp format_row({count, ref,
      %{"first_name" => first, "last_name" => last, "email" => email,
        "phone" => phone}}) do

    "#{ref}, #{count}, #{first}, #{last}, #{email}, #{phone}"
  end
end
