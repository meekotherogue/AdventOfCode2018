defmodule SortData do
  def parse([""], accumulator) do
    accumulator
  end

  def parse(entries, accumulator) do
    [head | tail] = entries

    [dateDum | [info | _]] = String.split(head, "] ")
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
    entry = %{"date" => dateObject, "info" => info, "timestamp" => dateObject |> DateTime.to_unix(:second)}

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

{:ok, entries} = File.open "Part4Adata.txt", [:read], fn(file) ->
  IO.read(file, :all)
end

split = String.split(entries, "\n")

IO.inspect(SortData.parse(split, []))
