defmodule Core.LayoutView do
  use Core.Web, :view

  def get_footer_links(brand) do
    %{body: {:ok, %{"object" => %{
      "content" => html
    }}}} = Cosmic.get "#{brand}-footer-links"
  
    html
  end
end
