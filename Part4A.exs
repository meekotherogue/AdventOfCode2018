defmodule SortData do
  def parse([""], accumulator) do
    accumulator
  end

  def parse(entries, accumulator) do
    [head | tail] = entries

    [dateDum | [info | _]] = String.split(head, "] ")
    type = cond do
      String.contains?(info, "falls") -> :asleep
      String.contains?(info, "wakes") -> :awake
      String.contains?(info, "Guard #") -> List.first(Regex.run(~r/\d+/, info))
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
    type = head["type"]

    minutesAsleep = parseGuard(head, tail, 0, head, :awake, 0)

    newAcc = cond do
      type != :asleep && type != :awake ->
        newMinutes = cond do
          Map.get(accumulator, type) == nil -> minutesAsleep
          Map.get(accumulator, type) != nil -> Map.get(accumulator, type) + minutesAsleep
        end
        Map.put(accumulator, type, newMinutes)
      type == :asleep || type == :awake -> accumulator
    end

    parse(tail, newAcc)
  end

  defp parseGuard(_, _, accumulator, _, :newGuard, _) do
    accumulator
  end

  defp parseGuard(_, [], accumulator, _, _, _) do
    accumulator
  end

  defp parseGuard(guardEntry, entries, accumulator, currentGuard, currentState, asleepMinute) do
    [newGuard | tail] = entries

    newState = cond do
      newGuard["type"] == :asleep || newGuard["type"] == :awake -> newGuard["type"]
      newGuard["type"] != :asleep && newGuard["type"] != :awake -> :newGuard
    end

    accumulator = case newState do
      :awake -> accumulator + (newGuard["date"].minute - asleepMinute)
      :asleep -> accumulator
      :newGuard -> accumulator
    end

    parseGuard(newGuard, tail, accumulator, currentGuard, newState, newGuard["date"].minute)
  end
end

{:ok, entries} = File.open "Part4Adata.txt", [:read], fn(file) ->
  IO.read(file, :all)
end

split = String.split(entries, "\n")
sorted = SortData.parse(split, [])
# IO.inspect(sorted)
IO.inspect(GetGuard.parse(sorted, Map.new()))
