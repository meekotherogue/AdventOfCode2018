defmodule GetValue do
  def parse([], accumulator) do
    accumulator[:twice] * accumulator[:thrice]
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

    right = leftInt + widthInt
    columnNums = Enum.to_list(leftInt..right)

    bottom = topInt + heightInt
    rowNums = Enum.to_list(topInt..bottom)

    newAcc = Enum.reduce(columnNums, accumulator, fn (columnNum, colAcc) ->
      colAcc = Enum.reduce(rowNums, accumulator, fn (rowNum, rowAcc) ->
        row = rowAcc[rowNum]
        newRow = cond do
          row == nil -> %{columnNum => :free}
          row != nil -> row
        end
        rowAcc = put_in rowAcc[rowNum], newRow

        currentValue = newRow[columnNum]
        newValue = cond do
          currentValue == nil -> :taken
          currentValue == :free -> :taken
          currentValue == :taken -> :overlap
          currentValue == :overlap -> :overlap
        end

        rowAcc = put_in rowAcc[rowNum][columnNum], newValue
      end)
    end)
    IO.inspect(newAcc[top][left])
  end
end

{:ok, entries} = File.open "Part3Data.txt", [:read], fn(file) ->
  IO.read(file, :all)
end

split = String.split(entries, "\n")
# IO.inspect(split)
IO.puts(GetValue.parse(split, Map.new()))
