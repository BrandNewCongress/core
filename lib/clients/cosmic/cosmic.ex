defmodule Cosmic do
  def fetch_all() do
    %{body: {:ok, %{
      "bucket" => %{
        "objects" => objects
      }
    }}} = Cosmic.Api.get("")

    Enum.map(objects, fn bucket -> Stash.set(:cosmic_cache, bucket["slug"], bucket) end)
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

  def update() do
    Stash.clear(:cosmic_cache)
    fetch_all()
    IO.puts "Cleared cosmic cache and updated it"
  end
end
