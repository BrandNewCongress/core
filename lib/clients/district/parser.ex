defmodule District.Parser do
  def load_geojsons do
    {:ok, districts} =
      "./lib/clients/district/geojsons"
      |> File.ls()

    geojsons =
      districts
      |> Enum.map(fn district ->
           {:ok, file} = "./lib/clients/district/geojsons/#{district}" |> File.read()
           {:ok, %{"geometry" => geometry}} = file |> Poison.decode()

           geometry
           |> Geo.JSON.decode()
         end)

    districts
    |> Enum.map(fn str -> str |> String.split(".") |> List.first() end)
    |> Enum.zip(geojsons)
    |> Enum.into(%{})
  end
end
