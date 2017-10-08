defmodule Core.VoxController do
  @secret Application.get_env(:core, :update_secret)

  use Core.Web, :controller
  import Core.BrandHelpers

  def get(conn, params) do
    render conn, "vox.html", [title: "Call"] ++ GlobalOpts.get(conn, params)
  end

  def post(conn, params = %{"email" => email, "phone" => phone, "first" => first_name, "last" => last_name}) do
    global_opts = GlobalOpts.get(conn, params)
    brand = Keyword.get(global_opts, :brand)
    date = "#{"America/New_York" |> Timex.now() |> Timex.to_date}"

    person = %{tags: tags} = Osdi.Person.push(%{
      email_address: email, phone_number: phone,
      given_name: first_name, family_name: last_name
    })

    current_username =
      tags
      |> Enum.map(fn %{name: name} -> name end)
      |> Enum.filter(fn t -> String.contains?(t, "Vox Alias: #{copyright(brand)}") and String.contains?(t, date) end)
      |> Enum.map(fn t -> String.split(t, ":") end)
      |> Enum.map(fn [_vox_part, _brand_part, result, _date_part] -> String.trim(result) end)
      |> List.first()

    [username, password] = case current_username do
      nil -> Core.Vox.next_login(brand)
      un -> [un, Core.Vox.password_for(un, brand)]
    end

    Osdi.Person.add_tags(person, [
      "Action: Made Calls: #{copyright(brand)}",
      "Vox Alias: #{copyright(brand)}: #{username}: #{date}"
    ])

    %{"content" => call_page, "metadata" => metadata} = Cosmic.get("call-page")

    content_key = "#{Keyword.get(global_opts, :brand)}_content"
    chosen_content =
      if metadata[content_key] && metadata[content_key] != "" do
        metadata[content_key]
      else
        call_page
      end

    Task.async(fn ->
      Core.VoxMailer.on_vox_login_claimed(%{"username" => username, "date" => date,
        "first_name" => first_name, "last_name" => last_name, "email" => email,
        "phone" => phone, "source" => Keyword.get(global_opts, :brand)
      })
    end)

    render conn, "vox-submitted.html",
      [username: String.trim(username), password: String.trim(password), title: "Call",
       call_page: chosen_content] ++ global_opts
  end

  def get_logins(conn, %{"secret" => @secret}) do
    text conn, Core.Vox.logins_for_day
  end

  def get_report(conn, params = %{"secret" => @secret}) do
    render conn, "vox-report.html",
      [layout: {Core.LayoutView, "empty.html"}] ++ GlobalOpts.get(conn, params)
  end
end
