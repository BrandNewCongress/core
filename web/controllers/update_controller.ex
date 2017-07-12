defmodule Core.UpdateController do
  use Core.Web, :controller
  require Logger

  def cosmic(conn, _params) do
    json conn, %{"unnecessary" => "Ben implemented webhooks! No need to visit hit this link any more. If it's not updating, contact Ben. Thanks!"}
  end
end
