defmodule District do
  districts =
    "./lib/clients/district/geojsons"
    |> File.ls()

  geojsons =
    districts
    |> Enum.map(fn district ->
      district
      |> File.read()
      |> Poison.decode()
      |> Geo.JSON.decode()
     end)

  @geojsons districts |> Enum.zip(geojsons) |> Enum.into(%{})

  defp is_short_form(string) do
    case Regex.run(~r/[A-Za-z][A-Za-z]-[0-9]+/, string) do
      nil -> false
      _ -> true
    end
  end

  def from_address(string) do
    Maps.geocode(string)
  end

  def district_of_point({lat, lng}) do
    point = %Geo.Point{ coordinates: {lat, lng}, srid: nil }

    @geojsons
    |> Enum.filter(&(Topo.contains?(&1, point)))
    |> List.first()
  end
end
