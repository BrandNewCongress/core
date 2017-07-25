defmodule Congress.Parser do
  {:ok, legislators} = "./lib/clients/congress/legislators-current.json"
    |> File.read()
    |> (fn {:ok, raw} -> Poison.decode(raw) end).()

  @raw_legislators legislators

  def get_congress(district, legislators) do
    rep = legislators |> Enum.filter(&(is_rep_for(&1, district))) |> List.first()
    senate = legislators |> Enum.filter(&(is_sen_for(&1, district))) |> Enum.take(2)
    {district, %{house: rep, senate: senate}}
  end

  def is_rep(legislator) do
    case current_appointment(legislator) do
      %{"type" => "rep"} -> true
      _else -> false
    end
  end

  def state_of(legislator), do: current_appointment(legislator)["state"]
  def is_in_state(legislator, state), do: current_appointment(legislator)["state"] == state

  defp is_rep_for(legislator, district) do
    {state, district} = District.extract_int_form(district)
    case current_appointment(legislator) do
      %{"type" => "rep", "state" => ^state, "district" => ^district} -> true
      _else -> false
    end
  end

  defp is_sen_for(legislator, district) do
    {state, _district} = District.extract_int_form(district)
    case current_appointment(legislator) do
      %{"type" => "sen", "state" => ^state} -> true
      _else -> false
    end
  end

  def current_appointment(_legislator = %{"terms" => terms}), do: List.last(terms)

  def reps_by_state do
    areas = @raw_legislators
      |> Enum.filter_map(&is_rep/1, &state_of/1)
      |> MapSet.new()

    legislators_by_area = Enum.map(areas, fn area ->
      {area, @raw_legislators
        |> Enum.filter(&is_rep/1)
        |> Enum.filter(&(is_in_state(&1, area)))
        |> Enum.map(&extract_standup_attrs/1)
      }
    end)

    Enum.into(legislators_by_area, %{})
  end

  def extract_standup_attrs(legislator) do
    %{"party" => party, "district" => district, "state" => state} = current_appointment(legislator)
    %{"name" => %{"official_full" => name}} = legislator

    add_image(%{"party" => party, "district" => district, "state" => state, "name" => name})
  end

  def add_image(legislator) do
    %{"name" => name} = legislator
    %{body: %{"itemListElement" => entity_list}} = Entity.search(name)

    img = case List.first(entity_list) do
      %{"result" => %{"image" => %{"contentUrl" => img}}} -> img
      _else ->
        IO.puts "no image for #{name}"
        nil
    end

    Map.put(legislator, "img", img)
  end
end
