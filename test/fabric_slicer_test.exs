defmodule FabricSlicerTest do
  use ExUnit.Case, async: true
  import FabricSlicer
  doctest FabricSlicer

  setup_all do
    {:ok, puzzle_input} =
      Path.join([__DIR__, "inputs", "day_03.txt"])
      |> File.read()

    claims =
      puzzle_input
      |> String.split("\n", trim: true)

    %{claims: claims}
  end

  @tag :solution
  test "calculate_overused_fabric with input from puzzle", context do
    assert calculate_overused_fabric(context.claims, 1000, 1000) == 101_565
  end

  @tag :solution
  test "find_non_overlapping_claim with input from puzzle", context do
    assert find_non_overlapping_claim(context.claims) == 656
  end
end
