defmodule Core.Vox do
  use Swoosh.Mailer, otp_app: :core
  import Swoosh.Email

  # @words "./lib/clients/vox/words.csv"
  #   |> File.stream!()
  #   |> CSV.decode()
  #   |> Enum.map(fn {:ok, word} -> word end)

  # defp random_password do
  #   "#{@words |> Enum.take_random(1)}#{1..4 |> Enum.map(fn n -> Enum.random(1..9) end) |> Enum.join("")}"
  # end

  def next_login(email, phone) do
    short_email = String.slice(email, 0..2)
    short_phone = String.slice(phone, 0..2)
    [username, password] = ["#{short_email}#{short_phone}", "brandnew2018"]

    new()
    |> to({"Sam Briggs", "ben@brandnewcongress.org"})
    |> from({"Ben's Program", "us@mail.brandnewcongress.org"})
    |> subject("New Login Request!")
    |> text_body(text(username, password))
    |> deliver

    [username, password]
  end

  defp decode_logins(string) do
    string
    |> String.split("\n")
    |> Enum.map(fn line -> String.split(line, (",")) end)
  end

  defp text(username, password) do
    "
Username: #{username}
Password: #{password}
    "
  end
end
