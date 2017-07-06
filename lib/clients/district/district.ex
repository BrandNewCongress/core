defmodule District do
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

  @geojsons districts
    |> Enum.map(fn str -> str |> String.split(".") |> List.first() end)
    |> Enum.zip(geojsons) |> Enum.into(%{})

  defp is_short_form(string) do
    case Regex.run(~r/[A-Za-z][A-Za-z]-[0-9]+/, string) do
      nil -> false
      _ -> true
    end
  end

  defp normalize(string) do
    [state, cd] = String.split(string, "-")

    state = String.upcase(state)

    cd = case String.length(cd) do
      1 -> "0" <> cd
      2 -> cd
    end

    "#{state}-#{cd}"
  end

  def from_point({lat, lng}) do
    @geojsons
    |> Enum.filter_map(
        fn {district, polygon} -> Topo.contains?(polygon, {lat, lng}) end,
        fn {district, polygon} -> district end
      )
    |> List.first()
  end

  def from_address(string) do
    string
    |> Maps.geocode()
    |> from_point()
  end

  def from_unknown(string) do
    if is_short_form(string) do
      {normalize(string), nil}
    else
      {from_address(string), nil}
    end
  end
end
