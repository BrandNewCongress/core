defmodule Core.PetitionView do
  use Core.Web, :view
  import Core.BrandHelpers

  def csrf_token(_conn) do
    Plug.CSRFProtection.get_csrf_token
  end
end
