defmodule AlchemyReductionTest do
  use ExUnit.Case, async: true
  import AlchemyReduction
  doctest AlchemyReduction

  setup_all do
    puzzle_input =
      Path.join([__DIR__, "inputs", "day_05.txt"])
      |> File.read!()
      |> String.trim()

    %{
      puzzle_input: puzzle_input
    }
  end

  @tag :solution
  test "reduce_polymer with input from puzzle", context do
    {:ok, polymer, count} = reduce_polymer(context.puzzle_input)

    assert count == 11364
  end
end
