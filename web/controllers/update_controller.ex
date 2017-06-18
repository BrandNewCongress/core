defmodule Core.UpdateController do
  use Core.Web, :controller
  @secret Application.get_env(:core, :update_secret)

  def cosmic(conn, %{"secret" => @secret}) do
    Cosmic.update()
    json conn, %{"ok" => "Successfully updated Cosmic cache"}
  end

  def cosmic(conn, %{"secret" => _}) do
    json conn, %{"error" => "Wrong secret. Contact Ben for the right one."}
  end

  def cosmic(conn, _) do
    json conn, %{"error" => "Missing secret. Contact Ben for it."}
  end
end
