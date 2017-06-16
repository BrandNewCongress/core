defmodule Core.SubscriptionView do
  use Core.Web, :view

  def csrf_token(conn) do
    Plug.CSRFProtection.get_csrf_token
  end
end
