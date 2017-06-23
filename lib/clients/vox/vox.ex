defmodule Vox do
  @words "./lib/clients/vox/words.csv"
    |> File.stream!()
    |> CSV.decode()
    |> Enum.map(fn {:ok, word} -> word end)

  def logins_for_day do
    date = "#{Timex.now("America/New_York") |> Timex.to_date}"

    logins = case Mongo.find_one(:core, "logins", %{date: date}) do
      nil -> create_and_return_logins(date)
      %{"logins" => logins} -> logins
    end

    logins
    |> Enum.map(fn l -> Enum.join(l, ",") end)
    |> Enum.join("\n")
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

    Mongo.insert_one(:core, "logins", %{date: date, logins: logins, claimed: -1})

    logins
  end

  defp random_password do
    @words |> Enum.take_random(3) |> Enum.join("_")
  end

  def next_login() do
    date = "#{Timex.now("America/New_York") |> Timex.to_date}"

    {:ok, %{"claimed" => claimed, "logins" => logins}} =
      Mongo.find_one_and_update(:core, "logins", %{date: date}, %{"$inc": %{"claimed": 1}})

    [email | [password | _]] = Enum.at(logins, claimed, nil)
    [email, password]
  end

  def password_for(username) do
    date = "#{Timex.now("America/New_York") |> Timex.to_date}"

    %{"logins" => logins} = Mongo.find_one(:core, "logins", %{date: date})

    [password] =
      logins
      |> Enum.filter_map(
          fn [un | _] -> un == username end,
          fn [_ | [pwd | _]] -> pwd end
        )

    password
  end
end
