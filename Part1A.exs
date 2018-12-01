defmodule GetValue do
  def parse([], accumulator) do
    accumulator
  end

  def parse(entries, accumulator) do
    [head | tail] = entries
    symbol = String.slice(head, 0, 1)
    value = String.slice(head, 1, String.length(head))

    new_value = case symbol do
      "+" -> accumulator + String.to_integer(value)
      "-" -> accumulator - String.to_integer(value)
      _ -> accumulator
    end
    parse(tail, new_value)
  end
end

{:ok, entries} = File.open "dum.txt", [:read], fn(file) ->
  IO.read(file, :all)
end

IO.puts(GetValue.parse(String.split(entries, "\n"), 0))
