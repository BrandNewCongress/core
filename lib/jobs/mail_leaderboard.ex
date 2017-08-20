defmodule Core.Jobs.MailLeaderboard do
  def send do
    Core.LeaderboardHelpers.report_stream()
    |> Enum.to_list()
    |> Enum.sort(fn ({n1, _, _}, {n2, _, _}) -> n1 <= n2 end)
    |> Enum.map(&format_row/1)
    |> prepend_headers()
    |> Enum.join("\n")
    |> Core.LeaderboardMailer.send_leaderboard()
  end

  defp format_row({count, ref,
      %{"first_name" => first, "last_name" => last, "email" => email,
        "phone" => phone}}) do

    "#{ref}, #{count}, #{first}, #{last}, #{email}, #{phone}"
  end

  defp prepend_headers(list) do
    ["Ref Code, Count, First Name, Last Name, Email, Phone" | list]
  end
end
