defmodule Core.VoxController do
  @secret Application.get_env(:core, :update_secret)

  use Core.Web, :controller
  import Core.BrandHelpers

  def get(conn, params) do
    render conn, "vox.html", GlobalOpts.get(conn, params)
  end

  def post(conn, params = %{"email" => email, "phone" => phone, "first" => first_name, "last" => last_name}) do
    global_opts = GlobalOpts.get(conn, params)
    brand = Keyword.get(global_opts, :brand)
    date = "#{Timex.now("America/New_York") |> Timex.to_date}"

    %{"id" => id, "tags" => tags} = Nb.People.push(%{
      "email" => email, "phone" => phone,
      "first_name" => first_name, "last_name" => last_name
    })

    current_username =
      tags
      |> Enum.filter(fn t -> String.contains?(t, date) end)
      |> Enum.map(fn t -> String.split(t, ":") end)
      |> Enum.map(fn [_vox_part, result, _date_part] -> String.trim(result) end)
      |> List.first()

    [username, password] = case current_username do
      nil -> Core.Vox.next_login()
      un -> [un, Core.Vox.password_for(un)]
    end

    Nb.People.add_tags(id, [
      "Action: Made Calls: #{copyright(brand)}",
      "Vox Alias: #{username}: #{date}"
    ])

    render conn, "vox-submitted.html", [username: username, password: password] ++ GlobalOpts.get(conn, params)
  end

  def get_logins(conn, %{"secret" => @secret}) do
    text conn, Core.Vox.logins_for_day
  end
end
