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
      Enum.reduce(columnNums, outerAcc, fn (columnNum, innerAcc) ->
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

defmodule GetClaims do
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

    entry = %{"id" => id, "left" => leftInt, "top" => topInt, "width" => widthInt, "height" => heightInt}
    parse(tail, accumulator ++ [entry])
  end
end

defmodule GetUniqueClaim do
  def parse(_, [], accumulator) do
    accumulator
  end

  def parse(map, claims, accumulator) do
    [head | tail] = claims

    idInt = String.to_integer(head["id"])
    leftInt = head["left"]
    topInt = head["top"]
    widthInt = head["width"]
    heightInt = head["height"]

    right = leftInt + widthInt - 1
    columnNums = Enum.to_list(leftInt..right)

    bottom = topInt + heightInt - 1
    rowNums = Enum.to_list(topInt..bottom)

    idUnique = Enum.reduce(rowNums, true, fn (rowNum, outerAcc) ->
      Enum.reduce(columnNums, true, fn (columnNum, innerAcc) ->
        currentValue = map[rowNum][columnNum]
        cond do
          currentValue == :free -> false
          currentValue == :taken && innerAcc -> true
          currentValue == :taken && !innerAcc -> false
          currentValue == :overlap -> false
        end
      end) && outerAcc
    end)

    newAcc = cond do
      idUnique -> idInt
      !idUnique -> nil
    end

    newTail = cond do
      idUnique -> []
      !idUnique -> tail
    end

    parse(map, newTail, newAcc)
  end
end

{:ok, entries} = File.open "Part3Data.txt", [:read], fn(file) ->
  IO.read(file, :all)
end

split = String.split(entries, "\n")
# IO.inspect(split)
map = GetValue.parse(split, Map.new())
claims = GetClaims.parse(split, [])
IO.inspect(GetUniqueClaim.parse(map, claims, nil))
# 118840
