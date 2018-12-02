defmodule ChronalCalibration do
  @moduledoc """
  Day 1: [Advent of Code](https://adventofcode.com/2018/day/1)
  """

  @doc """

  Find the resulting requency drift after all changes in frequencies have
  been applied.

      iex> calculate_frequency_drift(["+1", "+1", "+1"])
      3

      iex> calculate_frequency_drift(["+1", "+1", "-2"])
      0

      iex> calculate_frequency_drift(["-1", "-2", "-3"])
      -6

  """
  @spec calculate_frequency_drift([String.t()], integer) :: integer()
  def calculate_frequency_drift(frequency_changes, total_drift \\ 0)

  def calculate_frequency_drift([], total_drift), do: total_drift

  def calculate_frequency_drift([frequency_change | rest], total_drift) do
    with {drift, ""} <- Integer.parse(frequency_change) do
      calculate_frequency_drift(rest, drift + total_drift)
    end
  end

  @doc """
  Finds the first frequency the calibration device reaches twice.

  Examples:

      iex> find_first_seen_twice(["+1", "-1"])
      0

      iex> find_first_seen_twice(["+3", "+3", "+4", "-2", "-4"])
      10

      iex> find_first_seen_twice(["-6", "+3", "+8", "+5", "-6"])
      5

      iex> find_first_seen_twice(["+7", "+7", "-2", "-7", "-4"])
      14

  """
  @spec find_first_seen_twice([String.t()]) :: integer()
  def find_first_seen_twice(frequency_changes) do
    frequency_changes
    |> Stream.cycle()
    |> Enum.reduce_while({MapSet.new([0]), 0}, fn frequency_change, {seen_drifts, total_drift} ->
      with {drift, ""} <- Integer.parse(frequency_change),
           new_total_drift <- drift + total_drift do
        if MapSet.member?(seen_drifts, new_total_drift) do
          {:halt, new_total_drift}
        else
          {:cont, {MapSet.put(seen_drifts, new_total_drift), new_total_drift}}
        end
      end
    end)
  end
end
