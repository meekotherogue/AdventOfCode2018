defmodule GetValue do

  def parse(_, _, _, _, true, foundFrequency) do
    foundFrequency
  end

  def parse(entries, all_entries, accumulator, frequencies, false, _) do
    [head | tail] = entries
    symbol = String.slice(head, 0, 1)
    value = String.slice(head, 1, String.length(head))

    new_value = case symbol do
      "+" -> accumulator + String.to_integer(value)
      "-" -> accumulator - String.to_integer(value)
      _ -> accumulator
    end

    new_list = cond do
      length(tail) == 1 -> all_entries
      length(tail) > 1 -> tail
    end
    parse(new_list, all_entries, new_value, frequencies ++ [new_value], Enum.member?(frequencies, new_value), new_value)
  end
end

{:ok, entries} = File.open "dum.txt", [:read], fn(file) ->
  IO.read(file, :all)
end

split = String.split(entries, "\n");

IO.puts(GetValue.parse(split, split, 0, [], false, 0))
