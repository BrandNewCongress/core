defmodule Core.LeaderboardMailer do
  use Phoenix.Swoosh,
    view: Core.EmailView,
    layout: {Core.EmailView, :email}

  require Logger

  def send_leaderboard(raw) do
    Logger.info("Sending regular leaderboard email to Sam")

    new()
    |> to({"Sam Briggs", "sam@brandnewcongress.org"})
    |> to({"Ben Packer", "ben@brandnewcongress.org"})
    |> from({"Robot", "robot@brandnewcongress.org"})
    |> subject("Leaderboard Update!")
    |> render_body("event-failure.text", %{raw: raw})
    |> Core.Mailer.deliver()
  end
end
