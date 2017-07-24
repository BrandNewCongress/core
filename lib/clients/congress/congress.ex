defmodule Congress do
  require Congress.Parser

  {:ok, legislators} = "./lib/clients/congress/legislators-current.json"
    |> File.read()
    |> (fn {:ok, raw} -> Poison.decode(raw) end).()

  @congress District.list()
    |> Enum.map(&(Congress.Parser.get_congress(&1, legislators)))
    |> Enum.into(%{})

  def house_for(district) do
    %{house: rep} = @congress[district]
    rep
  end

  def senate_for(district) do
    %{senate: sen} = @congress[district]
    sen
  end
end
