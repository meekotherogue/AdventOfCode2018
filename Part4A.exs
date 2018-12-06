defmodule SortData do
  def parse([""], accumulator) do
    accumulator
  end

  def parse(entries, accumulator) do
    [head | tail] = entries

    [dateDum | [info | _]] = String.split(head, "] ")
    type = cond do
      !String.contains?(info, "Guard #") -> :info
      String.contains?(info, "Guard #") -> Regex.run(~r/\d+/, info)
    end

    [_ | [datetime | _]] = String.split(dateDum, "[")
    [date | [time | _]] = String.split(datetime, " ")
    [year | [month | [day | _]]] = String.split(date, "-")
    [hour | [minute | _]] = String.split(time, ":")

    year = String.to_integer(year)
    month = String.to_integer(month)
    day = String.to_integer(day)
    hour = String.to_integer(hour)
    minute = String.to_integer(minute)

    dateObject = %DateTime{year: year, month: month, day: day, hour: hour, minute: minute, second: 00, utc_offset: -14400, std_offset: 0, time_zone: "America/Manaus", zone_abbr: "AMT"}
    entry = %{"type" => type, "date" => dateObject, "info" => info, "timestamp" => dateObject |> DateTime.to_unix(:second)}

    accumulator = accumulator ++ [entry]

    newAcc = cond do
      length(accumulator) > 1 -> accumulator |> Enum.sort(fn (el1, el2) ->
          el1["timestamp"] < el2["timestamp"]
        end)
        length(accumulator) <= 1 -> accumulator
      end

    parse(tail, newAcc)
  end
end

defmodule GetGuard do
  def parse([], accumulator) do
    accumulator
  end

  def parse(entries, accumulator) do
    [head | tail] = entries
    [_ | [allInfo| _]] = String.split(head["info"], "#")
    [id | _] = String.split(allInfo, " ")
    IO.inspect(id)
  end
end

{:ok, entries} = File.open "Part4Adata.txt", [:read], fn(file) ->
  IO.read(file, :all)
end

split = String.split(entries, "\n")
sorted = SortData.parse(split, [])
IO.inspect(sorted)
# IO.inspect(GetGuard.parse(sorted, []))
