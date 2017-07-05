defmodule Cosmic do
  require Logger

  def fetch_all() do
    try do
      %{body: {:ok, %{
        "bucket" => %{
          "objects" => objects
        }
      }}} = Cosmic.Api.get("")

      # Store each object
      Enum.each(objects, fn bucket -> Stash.set(:cosmic_cache, bucket["slug"], bucket) end)

      # For each type, store an array of slugs
      objects
      |> Enum.map(fn %{"type_slug" => type} -> type end)
      |> MapSet.new
      |> Enum.each(fn type ->
          matches =
            objects
            |> Enum.filter(fn %{"type_slug" => match} -> match == type end)
            |> Enum.map(fn %{"slug" => slug} -> slug end)

          Stash.set(:cosmic_cache, type, matches)
        end)

      Stash.persist(:cosmic_cache, "./cosmic_cache")
    rescue
      _e in MatchError ->
        Logger.error("Could not fetch cosmic data - using latest cached version")
        Stash.load(:cosmic_cache, "./cosmic_cache")
    end
  end

  defp on_no_exist(path) do
    IO.puts "Path #{path} is not cached. fetching..."
    resp = Cosmic.Api.get(path)
    Stash.set(:cosmic_cache, path, resp)
    resp
  end

  def get(path) do
    case Stash.get(:cosmic_cache, path) do
      nil -> on_no_exist(path)
      val -> val
    end
  end

  def get_type(type) do
    type
    |> (fn t -> Stash.get(:cosmic_cache, t) end).()
    |> Enum.map(&(Stash.get(:cosmic_cache, &1)))
  end

  def update() do
    Stash.clear(:cosmic_cache)
    fetch_all()
    Logger.info "Cleared cosmic cache and updated it"
  end
end
