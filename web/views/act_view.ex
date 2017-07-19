defmodule Core.ActView do
  use Core.Web, :view

  def csrf_token() do
    Plug.CSRFProtection.get_csrf_token
  end
end
