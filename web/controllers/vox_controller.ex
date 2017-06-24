defmodule Core.VoxController do
  @secret Application.get_env(:core, :update_secret)

  use Core.Web, :controller
  import Core.BrandHelpers

  def get(conn, params) do
    render conn, "vox.html", GlobalOpts.get(conn, params)
  end

  def post(conn, params = %{"email" => email, "phone" => phone}) do
    global_opts = GlobalOpts.get(conn, params)
    brand = Keyword.get(global_opts, :brand)

    [username, password] = Core.Vox.next_login(email, phone)
    render conn, "vox-submitted.html", [username: username, password: password] ++ GlobalOpts.get(conn, params)
  end
end
