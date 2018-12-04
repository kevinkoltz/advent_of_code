defmodule InventoryManagementSystemTest do
  use ExUnit.Case, async: true
  import InventoryManagementSystem
  doctest InventoryManagementSystem

  setup_all do
    {:ok, puzzle_input} =
      Path.join([__DIR__, "inputs", "day_02.txt"])
      |> File.read()

    box_ids =
      puzzle_input
      |> String.split("\n", trim: true)

    %{box_ids: box_ids}
  end

  test "calculate_checksum with input from puzzle", context do
    assert calculate_checksum(context.box_ids) == 6150
  end

  test "find_fabric_prototype_boxes with input from puzzle", context do
    assert find_fabric_prototype_boxes(context.box_ids) == "rteotyxzbodglnpkudawhijsc"
  end
end
