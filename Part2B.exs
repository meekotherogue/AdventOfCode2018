defmodule GetValue do
  def parse([], diffCharacters) do
    diffCharacters
  end

  def parse(entries, _) do
    [head | tail] = entries

    diffCharacters = processEntry(head, tail, [])
    charactersForCompare = String.graphemes(head)

    returnTail = cond do
      length(diffCharacters) == length(charactersForCompare) - 1 -> []
      length(diffCharacters) != length(charactersForCompare) - 1 -> tail
    end
    parse(returnTail, diffCharacters)
  end

  defp processEntry(_, [], diffCharacters) do
    diffCharacters
  end

  defp processEntry(entry, allEntries, _) do
    charactersForEntry = String.graphemes(entry)
    [head | tail] = allEntries
    charactersForCompare = String.graphemes(head)

    diffCharacters = processCharacters(charactersForEntry, charactersForCompare, [], 0)

    returnTail = cond do
      length(diffCharacters) == length(charactersForEntry) - 1 -> []
      length(diffCharacters) != length(charactersForEntry) - 1 -> tail
    end
    processEntry(entry, returnTail, diffCharacters)
  end

  defp processCharacters([], [], diffCharacters, index) do
    diffCharacters
  end

  defp processCharacters(entry, compare, diffCharacters, index) do
    [entryChar | entryRemain] = entry
    [compareChar | compareRemain] = compare
    diffCharacters = cond do
      entryChar == compareChar -> diffCharacters ++ [entryChar]
      entryChar != compareChar -> diffCharacters
    end
    processCharacters(entryRemain, compareRemain, diffCharacters, index + 1)
  end
end

{:ok, entries} = File.open "Part2Data.txt", [:read], fn(file) ->
  IO.read(file, :all)
end

split = String.split(entries, "\n")

IO.puts(GetValue.parse(split, []))
