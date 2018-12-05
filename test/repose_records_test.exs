defmodule ReposeRecordsTest do
  use ExUnit.Case, async: true
  import ReposeRecords
  doctest ReposeRecords

  setup_all do
    {:ok, puzzle_input} =
      Path.join([__DIR__, "inputs", "day_04.txt"])
      |> File.read()

    repose_records =
      puzzle_input
      |> String.split("\n", trim: true)

    %{repose_records: repose_records}
  end

  test "find_guard with example input" do
    input =
      """
      [1518-11-01 00:00] Guard #10 begins shift
      [1518-11-01 00:05] falls asleep
      [1518-11-01 00:25] wakes up
      [1518-11-01 00:30] falls asleep
      [1518-11-01 00:55] wakes up
      [1518-11-01 23:58] Guard #99 begins shift
      [1518-11-02 00:40] falls asleep
      [1518-11-02 00:50] wakes up
      [1518-11-03 00:05] Guard #10 begins shift
      [1518-11-03 00:24] falls asleep
      [1518-11-03 00:29] wakes up
      [1518-11-04 00:02] Guard #99 begins shift
      [1518-11-04 00:36] falls asleep
      [1518-11-04 00:46] wakes up
      [1518-11-05 00:03] Guard #99 begins shift
      [1518-11-05 00:45] falls asleep
      [1518-11-05 00:55] wakes up
      """
      |> String.split("\n", trim: true)

    {:ok, guard_id, minutes_slept} = find_guard(input)

    assert guard_id * minutes_slept == 240
  end

  @tag :solution
  test "find_guard with input from puzzle", context do
    {:ok, guard_id, minutes_slept} = find_guard(context.repose_records)

    assert guard_id * minutes_slept == 94040
  end
end
