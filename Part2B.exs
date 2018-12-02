defmodule GetValue do
  def parse([], sameChars) do
    sameChars
  end

  def parse(entries, _) do
    [head | tail] = entries

    sameChars = processEntry(head, tail, [])
    charactersForCompare = String.graphemes(head)

    returnTail = cond do
      length(sameChars) == length(charactersForCompare) - 1 -> []
      length(sameChars) != length(charactersForCompare) - 1 -> tail
    end
    parse(returnTail, sameChars)
  end

  defp processEntry(_, [], sameChars) do
    sameChars
  end

  defp processEntry(entry, allEntries, _) do
    charactersForEntry = String.graphemes(entry)
    [head | tail] = allEntries
    charactersForCompare = String.graphemes(head)

    sameChars = processCharacters(charactersForEntry, charactersForCompare, [])

    returnTail = cond do
      length(sameChars) == length(charactersForEntry) - 1 -> []
      length(sameChars) != length(charactersForEntry) - 1 -> tail
    end
    processEntry(entry, returnTail, sameChars)
  end

  defp processCharacters([], [], sameChars) do
    sameChars
  end

  defp processCharacters(entry, compare, sameChars) do
    [entryChar | entryRemain] = entry
    [compareChar | compareRemain] = compare
    sameChars = cond do
      entryChar == compareChar -> sameChars ++ [entryChar]
      entryChar != compareChar -> sameChars
    end
    processCharacters(entryRemain, compareRemain, sameChars)
  end
end

{:ok, entries} = File.open "Part2Data.txt", [:read], fn(file) ->
  IO.read(file, :all)
end

split = String.split(entries, "\n")

IO.puts(GetValue.parse(split, []))

# megsdlpulxvinkatfoyzxcbvq
