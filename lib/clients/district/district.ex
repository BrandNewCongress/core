defmodule District do
  import District.GeoJson

  @mile_limit 10
  @miles_per_degree 69

  def get_gjs, do: geojsons()
  def get_polygon_of(district), do: geojsons()[district]
  def list, do: Map.keys(geojsons())

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

  @spec normalize(binary) :: binary
  @doc ~S"""
  Turns a variety of district formats into NY-14
  (capital letter, capital letter, dash, zero padded number)

  ## Examples
      iex> District.normalize("ny-14")
      "NY-14"

      iex> District.normalize("ny14")
      "NY-14"

      iex> District.normalize("ny 14")
      "NY-14"

      iex> District.normalize("ny 7")
      "NY-07"

      iex> District.normalize("sd-al")
      "SD-00"

      iex> District.normalize("sd 0")
      "SD-00"
  """
  def normalize(string) do
    processed =
      string
      |> String.upcase()
      |> String.replace("AL", "00")

    case Regex.named_captures(~r/(?<state>[A-Z]{2,})[ -]?(?<district>([0-9]{1,2}))/, processed) do
      %{"district" => district, "state" => state} ->
        "#{state}-#{district |> String.pad_leading(2, "0")}"
      nil ->
        nil
    end
  end

  @spec from_point({number, number}) :: binary
  @doc ~S"""
  Transforms a latitude longitude pair into a string of its containing US
  congressional district

  nil if not in the US.

  ## Examples
      iex> District.from_point({43.7022454, -72.293365})
      "NH-02"

      iex> District.from_point({41.1478865, -73.8534775})
      "NY-17"
  """
  def from_point({lat, lng}) do
    geojsons()
    |> Enum.filter(fn {_district, polygon} -> Topo.contains?(polygon, {lng, lat}) end)
    |> Enum.map(fn {district, _polygon} -> district end)
    |> List.first()
  end

  @spec from_address(binary) :: binary
  def from_address(string) do
    string
    |> Maps.geocode()
    |> from_point()
  end

  @spec from_unknown(binary) :: {binary, {number, number}}
  def from_unknown(string) do
    district = if is_short_form(string) do
      normalize(string)
    else
      from_address(string)
    end

    geoj = geojsons() |> Map.take([district])
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

    candidate_geos = Map.take(geojsons(), candidate_districts)

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
    geojsons()
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
