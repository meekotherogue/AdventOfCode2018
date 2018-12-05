defmodule GetValue do
  def parse([], accumulator) do
    accumulator
  end

  def parse(entries, accumulator) do
    [head | tail] = entries

    [_ | [data | _]] = String.split(head, " @ ")
    [coords | [area | _]] = String.split(data, ": ")
    [left | [top | _]] = String.split(coords, ",")
    [width | [height | _]] = String.split(area, "x")

    leftInt = String.to_integer(left)
    topInt = String.to_integer(top)
    widthInt = String.to_integer(width)
    heightInt = String.to_integer(height)

    right = leftInt + widthInt - 1
    columnNums = Enum.to_list(leftInt..right)

    bottom = topInt + heightInt - 1
    rowNums = Enum.to_list(topInt..bottom)

    newAcc = Enum.reduce(rowNums, accumulator, fn (rowNum, outerAcc) ->
      newRow = Enum.reduce(columnNums, outerAcc, fn (columnNum, innerAcc) ->
        currentValue = innerAcc[rowNum][columnNum]
        newValue = cond do
          currentValue == nil -> :taken
          currentValue == :free -> :taken
          currentValue == :taken -> :overlap
          currentValue == :overlap -> :overlap
        end

        Map.update(innerAcc, rowNum, %{columnNum => :taken}, fn (currentValueMap) ->
          Map.put(currentValueMap, columnNum, newValue)
        end)
      end)
    end)
    parse(tail, newAcc)
  end
end

defmodule ParseMap do
  def parse([], accumulator) do
    accumulator
  end

  def parse(entries, accumulator) do
    [row | tail] = entries

    newAcc = parseColumns(Map.values(row), accumulator)
    parse(tail, newAcc)
  end

  defp parseColumns([], accumulator) do
    accumulator
  end

  defp parseColumns(columns, accumulator) do
    [column | tail] = columns

    newAcc = cond do
      column == :overlap -> accumulator + 1
      column != :overlap -> accumulator
    end

    parseColumns(tail, newAcc)
  end
end

{:ok, entries} = File.open "Part3Data.txt", [:read], fn(file) ->
  IO.read(file, :all)
end

split = String.split(entries, "\n")
# IO.inspect(split)
map = GetValue.parse(split, Map.new())
IO.puts(ParseMap.parse(Map.values(map), 0))
# 118840
