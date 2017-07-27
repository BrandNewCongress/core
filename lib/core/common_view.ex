defmodule Core.CommonView do
  def csrf_token() do
    Plug.CSRFProtection.get_csrf_token
  end
end
