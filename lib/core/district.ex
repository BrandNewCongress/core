defmodule District do
  defp is_short_form(string) do
    case Regex.run(~r/[A-Za-z][A-Za-z]-[0-9]+/, string) do
      nil -> false
      _ -> true
    end
  end

  def from_address(string) do
    Maps.geocode(string)
  end
end
