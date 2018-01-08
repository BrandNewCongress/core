defmodule EncrichCsv do
  alias NimbleCSV.RFC4180, as: CSV

  @degree_limit 1.449 * 10

  def go do
    {:ok, out} = File.open("out.csv", [:write])

    events =
      EventProxy.stream("events")
      |> Enum.to_list()
      |> Enum.map(fn e ->
           e
           |> Map.put(:start_date, EventHelp.parse(e.start_date))
           |> Map.put(:end_date, EventHelp.parse(e.end_date))
         end)
      |> Enum.filter(fn e ->
           e.status == "confirmed" and Timex.after?(e.start_date, Timex.now())
         end)
      |> Enum.map(&EventHelp.add_date_line/1)

    {:ok, pid} = NearestEvents.start_link()

    File.stream!("./big.csv")
    |> CSV.parse_stream()
    |> Stream.with_index()
    |> Flow.from_enumerable()
    |> Flow.map(fn {row, idx} -> encrich_row(idx, row, events) end)
    |> Flow.map(fn row -> write_row(row, out) end)
    |> Flow.run()

    File.close(out)
  end

  def encrich_row(idx, row, events) do
    IO.inspect idx
    zip = List.last(row) |> String.split(",") |> Enum.reverse() |> Enum.at(1) |> String.trim() |> String.split("-") |> List.first()
    three = NearestEvents.three_nearest(zip, events)

    extra =
      Enum.flat_map(three, fn ev ->
        candidate_tag = ev.tags |> Enum.filter(fn t -> String.contains?(t, "Calendar") and not String.contains?(t, "Justice") and not String.contains?(t, "Brand") end) |> List.first()
        candidate =
          case candidate_tag do
            "Calendar: " <> cand -> cand
            nil -> "JD"
          end

        [ev.browser_url, ev.title, ev.date_line, ev.contact.name, candidate]
      end)

    result = Enum.reverse(row) |> Enum.slice(1, 99) |> Enum.reverse() |> Enum.concat(extra)
  end

  def write_row(row, pid) do
    phones = Enum.at(row, 2)
    first = String.split(phones, ",") |> List.first()
    row = List.replace_at(row, 2, first)

    IO.inspect IO.binwrite(pid, (row |> Enum.map(& ~s("#{&1}")) |> Enum.join(",")) <> "\n")
  end
end

defmodule NearestEvents do
  alias NimbleCSV.RFC4180, as: CSV

  @easy_float fn flt ->
    {x, _} = flt |> String.trim() |> Float.parse()
    x
  end

  @zips File.stream!("zips.csv")
    |> CSV.parse_stream()
    |> Flow.from_enumerable()
    |> Flow.map(fn [zip, lat, lng] -> {zip, [@easy_float.(lat), @easy_float.(lng)]} end)
    |> Enum.into(%{})

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def three_nearest(zip, events) do
    case Agent.get(__MODULE__, fn state -> Map.get(state, zip, nil) end) do
      nil ->
        three = compute_three_nearest(zip, events)
        Agent.update(__MODULE__, fn state -> Map.put(state, zip, three) end)
        three

      three ->
        three
    end
  end

  def compute_three_nearest(zip, events) do
    center = @zips[zip]

    if center do
      events
      |> Enum.sort_by(fn ev ->
           naive_distance(center, ev.location.location)
         end)
       |> Enum.filter(fn ev ->
         naive_distance(center, ev.location.location) < @degree_limit
       end)
      |> Enum.take(3)
    else
      []
    end
  end

  def naive_distance([x1, y1], [x2, y2]) do
    :math.sqrt(:math.pow(y2 - y1, 2) + :math.pow(x2 - x1, 2))
  end
end
