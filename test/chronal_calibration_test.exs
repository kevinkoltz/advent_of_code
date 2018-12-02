defmodule ChronalCalibrationTest do
  use ExUnit.Case, async: true
  import ChronalCalibration
  doctest ChronalCalibration

  setup_all do
    {:ok, puzzle_input} =
      Path.join(__DIR__, "day_01_input.txt")
      |> File.read()

    frequency_changes =
      puzzle_input
      |> String.trim()
      |> String.split("\n")

    %{frequency_changes: frequency_changes}
  end

  test "calculate_frequency_drift with input from puzzle", context do
    assert ChronalCalibration.calculate_frequency_drift(context.frequency_changes) == 510
  end

  test "find_first_seen_twice with input from puzzle", context do
    assert ChronalCalibration.find_first_seen_twice(context.frequency_changes) == 69074
  end
end
