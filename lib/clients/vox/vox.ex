defmodule Vox do
  @words "./lib/clients/vox/words.csv"
    |> File.stream!()
    |> CSV.decode()
    |> Enum.map(fn {:ok, word} -> word end)

  def logins_for_day do
    date = "#{Timex.now("America/New_York") |> Timex.to_date}"

    logins = case Redix.command(:redix, ["GET", date]) do
      {:ok, nil} -> create_and_return_logins(date)
      {:ok, logins} -> logins
    end

    logins
  end

  defp create_and_return_logins(date) do
    logins =
      1..9000
      |> Enum.map(fn n -> [
            "bnc#{n}",
            random_password(),
            "BNC",
            "Volunteer",
            1234,
            30,
            "yes",
            "",
            "",
            1234,
            1,
            1
          ]
        end)
      |> Enum.map(fn l -> Enum.join(l, ",") end)
      |> Enum.join("\n")

    Redix.command(:redix, ["SET", date, logins])
    Redix.command(:redix, ["SET", "claimed", -1])

    logins
  end

  defp random_password do
    @words |> Enum.take_random(3) |> Enum.join("_")
  end

  def next_login() do
    date = "#{Timex.now("America/New_York") |> Timex.to_date}"

    {:ok, raw} = Redix.command(:redix, ["GET", date])
    {:ok, logins} = decode_logins(raw)

    {:ok, claimed} = Redix.command(:redix, ["INCR", "claimed"])

    [email | [password | _]] = Enum.at(logins, claimed, nil)
    [email, password]
  end

  def password_for(username) do
    date = "#{Timex.now("America/New_York") |> Timex.to_date}"

    {:ok, raw} = Redix.command(:redix, ["GET", date])
    logins = decode_logins(raw)

    [password] =
      logins
      |> Enum.filter_map(
          fn [un | _] -> un == username end,
          fn [_ | [pwd | _]] -> pwd end
        )

    password
  end

  defp decode_logins(string) do
    string
    |> String.split("\n")
    |> Enum.map(fn line -> String.split(line, (",")) end)
  end
end
