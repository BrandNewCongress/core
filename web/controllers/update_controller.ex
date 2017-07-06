defmodule Core.UpdateController do
  use Core.Web, :controller
  @secret Application.get_env(:core, :update_secret)

  require Logger

  def cosmic(conn, params) do
    json conn, %{"unnecessary" => "Ben implemented webhooks! No need to visit hit this link any more. If it's not updating, contact Ben. Thanks!"}
  end
end
