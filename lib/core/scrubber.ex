defmodule Core.Scrubber do
  def scrub(html) do
    HtmlSanitizeEx.markdown_html(html)
  end
end
