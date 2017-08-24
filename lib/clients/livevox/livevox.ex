defmodule LiveVox do
  import ShorterMaps

  def calls_in_last_week do
    now = DateTime.utc_now()
    yesterday = Timex.shift(now, days: -1)

    startDate = yesterday |> DateTime.to_unix(:millisecond)
    endDate = now |> DateTime.to_unix(:millisecond)
    showTermCodes = true

    LiveVox.Api.post "reporting/v5.0/standard/agent/activity",
      body: ~M(startDate, endDate, showTermCodes)
  end
end
