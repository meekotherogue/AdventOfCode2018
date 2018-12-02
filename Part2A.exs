defmodule GetValue do
  def parse([], accumulator) do
    accumulator[:twice] * accumulator[:thrice]
  end

  def parse(entries, accumulator) do
    [head | tail] = entries

    characters = String.graphemes(head)
    twice = countChars(characters, characters, 2, false)
    thrice = countChars(characters, characters, 3, false)

    parse(tail, [twice: accumulator[:twice] + twice, thrice: accumulator[:thrice] + thrice])
  end

  defp countChars(_, _, _, true) do
    1
  end

  defp countChars([], _, _, false) do
    0
  end

  defp countChars(characters, allCharacters, numChars, _) do
    [head | tail] = characters
    count = allCharacters |> Enum.count(& &1 == head)
    countChars(tail, allCharacters, numChars, count == numChars)
  end
end

{:ok, entries} = File.open "Part2Data.txt", [:read], fn(file) ->
  IO.read(file, :all)
end

split = String.split(entries, "\n")

IO.puts(GetValue.parse(split, [twice: 0, thrice: 0]))
