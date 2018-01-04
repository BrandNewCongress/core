defmodule Core.VoxController do
  @secret Application.get_env(:core, :update_secret)

  use Core.Web, :controller
  import Core.BrandHelpers
  import ShortMaps

  def get(conn, params) do
    render(conn, "vox.html", [title: "Call"] ++ GlobalOpts.get(conn, params))
  end

  def post(conn, params = ~m(email phone name)) do
    global_opts = GlobalOpts.get(conn, params)
    client = Keyword.get(global_opts, :brand)
    date = "#{"America/New_York" |> Timex.now() |> Timex.to_date()}"

    current_username = Ak.DialerLogin.existing_login_for_email(email, client)

    action_calling_from = params["calling_from"] || "unknown"

    [username, password] =
      case current_username do
        nil -> Core.Vox.next_login(client)
        un -> [un, Core.Vox.password_for(un, client)]
      end

    Ak.DialerLogin.record_login_claimed(~m(email phone name action_calling_from), username, client)
    %{"content" => call_page, "metadata" => metadata} = Cosmic.get("call-page")

    content_key = "#{Keyword.get(global_opts, :brand)}_content"

    chosen_content =
      if metadata[content_key] && metadata[content_key] != "" do
        metadata[content_key]
      else
        call_page
      end

    spawn(fn ->
      Core.VoxMailer.on_vox_login_claimed(
        Map.merge(~m(username date name email phone action_calling_from), %{"source" => client})
      )
    end)

    render(
      conn,
      "vox-submitted.html",
      [
        username: String.trim(username),
        password: String.trim(password),
        title: "Call",
        call_page: chosen_content
      ] ++ global_opts
    )
  end

  def get_logins(conn, %{"secret" => @secret}) do
    text(conn, Core.Vox.logins_for_day())
  end

  def get_report(conn, params = %{"secret" => @secret}) do
    render(
      conn,
      "vox-report.html",
      [layout: {Core.LayoutView, "empty.html"}] ++ GlobalOpts.get(conn, params)
    )
  end

  def get_iframe(conn, params = %{"client" => client}) do
    conn
    |> delete_resp_header("x-frame-options")
    |> render(
         "vox-iframe.html",
         client: client,
         layout: {Core.LayoutView, "empty.html"},
         use_post_sign: Map.has_key?(params, "post_sign"),
         post_sign_url: Map.get(params, "post_sign")
       )
  end

  def post_iframe(conn, params = ~m(email phone name client)) do
    date = "#{"America/New_York" |> Timex.now() |> Timex.to_date()}"

    current_username = Ak.DialerLogin.existing_login_for_email(email, client)

    [username, password] =
      case current_username do
        nil -> Core.Vox.next_login(client)
        un -> [un, Core.Vox.password_for(un, client)]
      end

    Ak.DialerLogin.record_login_claimed(~m(email phone name), username, client)

    spawn(fn ->
      Core.VoxMailer.on_vox_login_claimed(
        Map.merge(~m(username date name email phone), %{"source" => client})
      )
    end)

    conn
    |> delete_resp_header("x-frame-options")
    |> render(
         "vox-iframe-claimed.html",
         username: String.trim(username),
         password: String.trim(password),
         client: client,
         use_post_sign: Map.has_key?(params, "post_sign"),
         post_sign_url: Map.get(params, "post_sign"),
         layout: {Core.LayoutView, "empty.html"}
       )
  end

  def who_claimed(conn, params = ~m(client login)) do
    result =
      case Ak.DialerLogin.who_claimed(client, login) do
        ~m(email calling_from) -> ~m(email calling_from)
        nil -> %{error: "Not found"}
      end

    json(conn, result)
  end
end
