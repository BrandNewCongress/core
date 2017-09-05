defmodule Core.Vox do
  use Swoosh.Mailer, otp_app: :core

  @words "./lib/clients/vox/words.csv"
    |> File.stream!()
    |> CSV.decode()
    |> Enum.map(fn {:ok, word} -> word end)

  def logins_for_day do
    date = "#{"America/New_York" |> Timex.now() |> Timex.to_date}"

    logins = case Redix.command(:redix, ["GET", date]) do
      {:ok, nil} -> create_and_return_logins(date)
      {:ok, logins} -> logins
    end

    logins
  end

  def clear_logins do
    date = "#{"America/New_York" |> Timex.now() |> Timex.to_date}"
    Redix.command(:redix, ["DEL", date])
  end

  defp create_and_return_logins(date) do
    bnc_logins =
      1..1000
      |> Enum.map(fn n -> [
            "BNCVolunteer#{n}",
            random_password(),
            "BNC",
            "Vol#{n}",
            1234,
            30,
            1,
            0,
            "Callers",
            "",
            1_008_479,
            1_008_489,
            1_008_488,
            1_007_839
          ]
        end)
      |> Enum.map(fn l -> Enum.join(l, ",") end)
      |> Enum.join("\n")

    jd_logins =
      1..3000
      |> Enum.map(fn n -> [
            "JdVolunteer#{n}",
            random_password(),
            "JD",
            "Vol#{n}",
            1234,
            30,
            1,
            0,
            "Callers",
            "",
            1_008_479,
            1_008_489,
            1_008_488,
            1_007_839
          ]
        end)
      |> Enum.map(fn l -> Enum.join(l, ",") end)
      |> Enum.join("\n")

    Redix.command(:redix, ["SET", "bnc-logins", bnc_logins])
    Redix.command(:redix, ["SET", "jd-logins", jd_logins])
    Redix.command(:redix, ["SET", "bnc-claimed", -1])
    Redix.command(:redix, ["SET", "jd-claimed", -1])

    bnc_logins <> "\n" <> jd_logins
  end

  defp random_password do
    "#{@words |> Enum.take_random(1) |> Enum.join("_")}#{1..6 |> Enum.map(fn _n -> Enum.random(1..9) end) |> Enum.join("")}"
  end

  def next_login(brand) do
    {:ok, raw} = Redix.command(:redix, ["GET", "#{brand}-logins"])
    logins = decode_logins(raw)

    {:ok, claimed} = Redix.command(:redix, ["INCR", "#{brand}-claimed"])

    [email | [password | _]] = Enum.at(logins, claimed, nil)
    [email, password]
  end

  def password_for(username, brand) do
    {:ok, raw} = Redix.command(:redix, ["GET", "#{brand}-logins"])

    logins = decode_logins(raw)

    [password] =
      logins
      |> Enum.filter(fn [un | _] -> un == username end)
      |> Enum.map(fn [_ | [pwd | _]] -> pwd end)

    password
  end

  defp decode_logins(string) do
    string
    |> String.split("\n")
    |> Enum.map(fn line -> String.split(line, (",")) end)
  end
end
