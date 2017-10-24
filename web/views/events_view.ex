defmodule Core.EventsView do
  use Core.Web, :view

  def candidate_of(tags) do
    tags
    |> Enum.reject(& String.contains?(&1, "Justice Democrats") or String.contains?(&1, "Brand New Congress"))
    |> Enum.filter(& String.contains?(&1, "Calendar"))
    |> List.first()
  end

  def get_donate_url(nil), do: nil
  def get_donate_url(candidate) do
    %{"metadata" => %{"donate_url" => donate_url}} =
      candidate
      |> String.split(":")
      |> List.last()
      |> String.trim()
      |> String.downcase()
      |> String.replace(" ", "-")
      |> Cosmic.get()

    donate_url
  end
end
