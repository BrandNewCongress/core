defmodule Core.VoxView do
  use Core.Web, :view

  def csrf_token(_conn) do
    Plug.CSRFProtection.get_csrf_token
  end
end
