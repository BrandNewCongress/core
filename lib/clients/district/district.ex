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

  @mile_limit 10
  @miles_per_degree 69

  def get_gjs, do: @geojsons
  def get_polygon_of(district), do: @geojsons[district]
  def list, do: Map.keys(@geojsons)

  def extract_int_form(string) do
    [state, district] = String.split(string, "-")
    {result, _} = Integer.parse(district)
    {state, result}
  end

  def is_short_form(string) do
    case Regex.run(~r/[A-Za-z][A-Za-z][-]?[0-9]+/, string) do
      nil -> false
      _ -> true
    end
  end

  def normalize(string) do
    cond do
      String.contains?(string, "-") ->
        [state, cd] = String.split(string, "-")
        state = String.upcase(state)
        cd = case String.length(cd) do
          1 -> "0" <> cd
          2 -> cd
        end
        "#{state}-#{cd}"

      String.length(string) === 3 ->
        state = string |> String.slice(0..1) |> String.upcase()
        cd = "0" <> String.slice(string, 2..2)
        "#{state}-#{cd}"

      String.length(string) === 4 ->
        state = string |> String.slice(0..1) |> String.upcase()
        cd = String.slice(string, 2..3)
        "#{state}-#{cd}"
    end
  end

  def from_point({lat, lng}) do
    @geojsons
    |> Enum.filter_map(
        fn {_district, polygon} -> Topo.contains?(polygon, {lng, lat}) end,
        fn {district, _polygon} -> district end
      )
    |> List.first()
  end

  def from_address(string) do
    string
    |> Maps.geocode()
    |> from_point()
  end

  def from_unknown(string) do
    district = if is_short_form(string) do
      normalize(string)
    else
      from_address(string)
    end

    geoj = @geojsons |> Map.take([district])
    coordinates = if geoj |> Map.keys() |> length() > 0 do
      geoj |> centroid()
    else
      "Hmm, it doesn't seem like #{string} is a valid congressional district. Try typing your address and we'll figure it out."
    end

    {district, coordinates}
  end

  def get_candidate(string) do
    "candidates"
    |> Cosmic.get_type()
    |> Enum.filter(fn %{"metadata" => %{"district" => district}} -> district == string end)
    |> List.first()
  end

  def closest_candidate({x, y}) do
    candidates =
      "candidates"
      |> Cosmic.get_type()

    candidate_districts =
      candidates
      |> Enum.map(fn %{"metadata" => %{"district" => district}} -> district end)

    candidate_geos = Map.take(@geojsons, candidate_districts)

    {closest_name, closest_dist} =
      candidate_geos
      |> Enum.map(&centroid/1)
      |> Enum.map(fn {key, centroid} -> {key, naive_distance({x, y}, centroid)} end)
      |> Enum.map(fn {key, dist} -> {key, dist * @miles_per_degree} end)
      |> Enum.sort(fn ({_l1, d1}, {_l2, d2}) -> d2 >= d1 end)
      |> List.first()

    if closest_dist < @mile_limit do
      candidates
      |> Enum.filter(fn %{"metadata" => %{"district" => district}} -> district == closest_name end)
      |> List.first()
    else
      nil
    end
  end

  def closest_candidate(district_string) do
    district_string
    |> centroid()
    |> closest_candidate()
  end

  def centroid(map = %{}) do
    key = map |> Map.keys() |> List.first()
    val = map[key]
    {_key, dist} = centroid({key, val})
    dist
  end

  def centroid({key, %Geo.MultiPolygon{coordinates: coordinates}}) do
    list =
      coordinates
      |> List.first()
      |> List.first()

    {sum_x, sum_y} = list |> Enum.reduce(fn ({x, y}, {acc_x, acc_y}) -> {acc_x + x, acc_y + y} end)
    {key, {sum_x / length(list), sum_y / length(list)}}
  end

  def centroid(district_string) when is_binary(district_string) do
    @geojsons
    |> Map.take([district_string])
    |> centroid()
  end

  def naive_distance({x1, y1}, {x2, y2}) do
    :math.sqrt((:math.pow(y2 - y1, 2) + :math.pow(x2 - x1, 2)))
  end

  def naive_distance_in_miles({x1, y1}, {x2, y2}) do
    (:math.sqrt((:math.pow(y2 - y1, 2) + :math.pow(x2 - x1, 2)))) * @miles_per_degree
  end
end
