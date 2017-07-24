defmodule Congress.Parser do
  def get_congress(district, legislators) do
    rep = legislators |> Enum.filter(&(is_rep_for(&1, district))) |> List.first()
    senate = legislators |> Enum.filter(&(is_sen_for(&1, district))) |> Enum.take(2)
    {district, %{house: rep, senate: senate}}
  end

  defp is_rep_for(legislator, district) do
    {state, district} = District.extract_int_form(district)
    case current_appointment(legislator) do
      %{"type" => "rep", "state" => ^state, "district" => ^district} -> true
      _else -> false
    end
  end

  defp is_sen_for(legislator, district) do
    {state, district} = District.extract_int_form(district)
    case current_appointment(legislator) do
      %{"type" => "sen", "state" => ^state} -> true
      _else -> false
    end
  end

  defp current_appointment(_legislator = %{"terms" => terms}), do: List.last(terms)
end
