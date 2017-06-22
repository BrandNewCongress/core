defmodule Zip do
  @meter_limit 80_467.2
  @coords "./lib/clients/zip/zipcodes.tsv"
    |> File.stream!()
    |> CSV.decode(separator: ?\t)
    |> Enum.map(fn
        {:ok, [lng, lat, zip]} -> {zip, [lat, lng]}
      end)
    |> (fn [_head | tail] -> tail end).()
    |> Enum.into(%{})

  def closest_candidate(zip) do
    candidates = Cosmic.get_type "candidates"

    meter_distances =
      candidates
      |> Enum.map(&get_zip/1)
      |> Enum.map(&(distance_task(&1, zip)))
      |> Enum.map(&Task.await/1)
      |> Enum.map(fn
          %{"rows" => [%{"elements" => [%{"distance" => %{"value" => meters}}]}| _]}
            -> meters
          _ # Likely because of invalid zip
            -> 10_000_000_000
          end)

    matches =
      candidates
      |> Enum.zip(meter_distances)
      |> Enum.filter_map(
          fn {_cand, meters} -> meters < @meter_limit end,
          fn {cand, _} -> cand end
        )

    case matches do
      [match | _] -> match
      _ -> nil
    end
  end

  defp get_zip(%{"metadata" => %{"zip" => zip}}), do: "#{zip}"
  defp distance_task(zip1, zip2) do
    Task.async(fn ->
        DistanceMatrixApi.TravelList.new
        |> DistanceMatrixApi.TravelList.add_entry(%{origin: "#{zip1}", destination: "#{zip2}"})
        |> DistanceMatrixApi.distances
    end)
  end

  def coords_of(zip) do
    @coords["#{zip}"]
  end
end
