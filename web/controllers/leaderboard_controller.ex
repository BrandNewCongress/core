defmodule Core.LeaderboardController do
  use Core.Web, :controller
  @secret Application.get_env(:core, :update_secret)

  def get(conn, params) do
    render conn, "get-ref-code.html", [title: "Ref Code"] ++ GlobalOpts.get(conn, params)
  end

  def post(conn, params = %{"email" => email, "phone" => phone, "first" => first_name, "last" => last_name}) do
    %{"id" => id, "tags" => tags} = Nb.People.push(%{
      "email" => email, "phone" => phone,
      "first_name" => first_name, "last_name" => last_name
    })

    current_code =
      tags
      |> Enum.filter(fn t -> String.contains?(t, "Recruiter Code:") end)
      |> Enum.map(fn t -> String.split(t, ":") end)
      |> Enum.map(fn [_vox_part, ref_code] -> String.trim(ref_code) end)
      |> List.first()

    code =
      if current_code != nil do
        current_code
      else
        code = String.slice(email, 0..2) <> String.slice(phone, 0..2)
        tag = "Recruiter Code: #{code}"

        Task.async(fn -> Nb.People.add_tags(id, [tag]) end)
        code
      end

    Nb.People.add_tags(id, [
      "Action: Claimed Recruiting Code: Brand New Congress"
    ])

    render conn, "got-ref-code.html",
      [code: code, title: "Recruiter Code", first_name: first_name] ++ GlobalOpts.get(conn, params)
  end

  def get_report(conn, params = %{"secret" => @secret}) do
    render conn, "leaderboard-report.html",
      [layout: {Core.LayoutView, "empty.html"}] ++ GlobalOpts.get(conn, params)
  end

  def send_email(conn, params = %{"secret" => @secret}) do
    Core.Jobs.MailLeaderboard.send()
    json conn, %{"ok" => "ok"}
  end
end
