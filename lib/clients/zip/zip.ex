defmodule Zip do
  @mile_limit 50

  @coords "./lib/clients/zip/zipcode.csv"
    |> File.stream!()
    |> CSV.decode()
    |> Enum.map(fn
        {:ok, [zip, _city, _state, lat, lng, timezone, _dst]} ->
          {Format.as_zip(zip), [Format.as_float(lat), Format.as_float(lng), Format.as_int(timezone)]}
      end)
    |> (fn [_head | tail] -> tail end).()
    |> Enum.into(%{})

  def closest_candidate(zip) do
    candidates = Cosmic.get_type "candidates"

    mile_distances =
      candidates
      |> Enum.map(&get_zip/1)
      |> Enum.map(&(distance_task(&1, zip)))
      |> Enum.map(&Task.await/1)

    matches =
      candidates
      |> Enum.zip(mile_distances)
      |> Enum.filter_map(
          fn {_cand, meters} -> meters < @mile_limit end,
          fn {cand, _} -> cand end
        )

    case matches do
      [match | _] -> match
      _ -> nil
    end
  end

  defp get_zip(%{"metadata" => %{"zip" => zip}}), do: "#{zip}"
  def distance_task(zip1, zip2) do
    Task.async(fn ->
      [lat1, lng1] = coords_of(zip1)
      [lat2, lng2] = coords_of(zip2)
      degrees = :math.sqrt((:math.pow(lat2 - lat1, 2) + :math.pow(lng2 - lng1, 2)))
      degrees * 69
    end)
  end

  def coords_of(zip) do
    [lat, lng, _] = @coords["#{zip}"]
    [lat, lng]
  end

  def time_zone_of(zip) do
    [_lat, _lng, timezone] = @coords["#{zip}"]
    as_string = "#{timezone}"

    full = case as_string do
      "-5" -> "Eastern Time (US & Canada)"
      "-6" -> "Central Time (US & Canada)"
      "-7" -> "Mountain Time (US & Canada)"
      "-8" -> "Pacific Time (US & Canada)"
      "-9" -> "Alaska"
      "-10" -> "Hawaii"
    end

    abbrev = case as_string do
      "-5" -> "EST"
      "-6" -> "CST"
      "-7" -> "MST"
      "-8" -> "PST"
      "-9" -> "AKST"
      "-10" -> "HST"
    end

    utc_offset = timezone * 3600
    [utc_offset, full, abbrev]
  end
end
