defmodule GetValue do
  def parse(_, matchedEntry = [_ | _]) do
    matchedEntry
  end

  def parse(entries, []) do
    [head | tail] = entries

    matchedEntry = processEntry(head, tail, [])

    parse(tail, matchedEntry)
  end

  defp processEntry(_, [], []) do
    []
  end

  defp processEntry(_, _, matchedEntry = [_ | _]) do
    matchedEntry
  end

  defp processEntry(entry, allEntries, _) do
    charactersForEntry = String.graphemes(entry)
    [head | tail] = allEntries
    charactersForCompare = String.graphemes(head)

    sameChars = processCharacters(charactersForEntry, charactersForCompare, [])

    matchedEntry = cond do
      length(sameChars) == length(charactersForCompare) - 1 -> sameChars
      length(sameChars) != length(charactersForCompare) - 1 -> []
    end
    processEntry(entry, tail, matchedEntry)
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
# megsdlpulxvinkatfoyzxcbvq
# megsdlpulxvinkatfoyzxcbvq
