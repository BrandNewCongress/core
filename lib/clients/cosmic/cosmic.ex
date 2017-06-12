defmodule Cosmic do
  defp on_no_exist(path) do
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
end
