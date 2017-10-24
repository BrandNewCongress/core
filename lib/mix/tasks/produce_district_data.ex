defmodule Mix.Tasks.ProduceDistrictData do
  use Mix.Task
  require Logger

  def run(_) do
    Logger.info("Creating district data")
    composite = District.Parser.load_geojsons()
    Stash.set(:district_cache, "district", composite)
    Stash.persist(:district_cache, "./lib/clients/district/district.ets")
  end
end
