defmodule District.GeoJson do
  Stash.load(:district_cache, "./lib/clients/district/district.ets")
  @geojsons Stash.get(:district_cache, "district")

  def geojsons do
    @geojsons
  end

end
