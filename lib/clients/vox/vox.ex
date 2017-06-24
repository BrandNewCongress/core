defmodule Core.Vox do
  use Swoosh.Mailer, otp_app: :core
  import Swoosh.Email

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
      1..8000
      |> Enum.map(fn n -> [
            "BNCVolunteer#{n}",
            random_password(),
            "BNC",
            "Vol#{n}",
            1234,
            30,
            1,
            0,
            "",
            "",
            1008479,
            1008489,
            1008488,
            1007839
          ]
        end)
      |> Enum.map(fn l -> Enum.join(l, ",") end)
      |> Enum.join("\n")

    Redix.command(:redix, ["SET", date, logins])
    Redix.command(:redix, ["SET", "claimed", -1])

    logins
  end

  defp random_password do
    "#{@words |> Enum.take_random(2) |> Enum.join("_")}#{1..4 |> Enum.map(fn n -> Enum.random(1..9) end) |> Enum.join("")}"
  end

  def next_login() do
    date = "#{Timex.now("America/New_York") |> Timex.to_date}"

    {:ok, raw} = Redix.command(:redix, ["GET", date])
    logins = decode_logins(raw)

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

  # def next_login(email, phone) do
  #   short_email = String.slice(email, 0..2)
  #   short_phone = String.slice(phone, 0..2)
  #   [username, password] = ["#{short_email}#{short_phone}", "brandnew2018"]
  #
  #   new()
  #   |> to({"Sam Briggs", "sam@brandnewcongress.org"})
  #   |> from({"Ben's Program", "us@mail.brandnewcongress.org"})
  #   |> subject("New Login Request!")
  #   |> text_body(text(username, password, email, phone))
  #   |> deliver
  #
  #   [username, password]
  # end

#   defp text(username, password, email, phone) do
#     "
# Username: #{username}
# Password: #{password}
# Email: #{email}
# Phone: #{phone}
#     "
#   end
end
