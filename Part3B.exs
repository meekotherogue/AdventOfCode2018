defmodule GetValue do
  def parse([], accumulator) do
    accumulator
  end

  def parse(entries, accumulator) do
    [head | tail] = entries

    [idNum | [data | _]] = String.split(head, " @ ")
    [_ | [id | _]] = String.split(idNum, "#")
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

        Map.update(innerAcc, rowNum, %{columnNum => [id]}, fn (currentValueMap) ->
          column = Map.get(currentValueMap, columnNum)

          newValue = cond do
            column == nil -> [id]
            column != nil -> column ++ [id]
          end
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

    IO.inspect(row)
    IO.inspect(Map.values(row))
    newAcc = parse2(Map.values(row), accumulator)
    IO.inspect(newAcc)
    # parse(tail, newAcc)
  end

  defp parse2([], accumulator) do
    accumulator
  end

  defp parse2(entries, accumulator) do
    [row | tail] = entries

    parse(tail, accumulator + length(row))
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
