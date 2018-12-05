defmodule ReposeRecords do
  defmodule Parser do
    @moduledoc """
    Parses a repose record log.

    Example logs:

    [1518-11-01 00:00] Guard #10 begins shift
    [1518-11-01 00:05] falls asleep
    [1518-11-01 00:25] wakes up

    """
    import NimbleParsec

    date =
      integer(4)
      |> ignore(string("-"))
      |> integer(2)
      |> ignore(string("-"))
      |> integer(2)

    time =
      integer(2)
      |> ignore(string(":"))
      |> integer(2)

    datetime =
      ignore(string("["))
      |> concat(date)
      |> ignore(string(" "))
      |> concat(time)
      |> ignore(string("]"))
      |> ignore(string(" "))

    wakes_up =
      wrap(datetime)
      |> ignore(string("wakes up"))
      |> tag("wakes_up")

    falls_asleep =
      wrap(datetime)
      |> ignore(string("falls asleep"))
      |> tag("falls_asleep")

    begins_shift =
      wrap(datetime)
      |> ignore(string("Guard #"))
      |> integer(min: 1)
      |> ignore(string(" begins shift"))
      |> tag("begins_shift")

    log_entry = choice([begins_shift, wakes_up, falls_asleep])

    defparsec(:parse, log_entry)
  end

  @doc """
  Find the guard who sleeps the most along with the time after midnight to sneak in (the time
  after midnight when the guard is most frequently asleep).
  """
  @spec find_guard([line :: String.t()]) ::
          {:ok, guard_id :: non_neg_integer(), minutes_slept :: non_neg_integer()}
  def find_guard(records) do
    {guard_id, best_minute} =
      records
      |> Enum.map(&Parser.parse/1)
      |> sort_by_time()
      |> find_naps()
      |> find_most_rested_guard()
      |> find_most_common_minute_asleep()

    {:ok, guard_id, best_minute}
  end

  defp sort_by_time(records) do
    Enum.sort_by(records, fn {:ok, [{_, [datetime | _id]}], "", _, _, _} -> datetime end)
  end

  defp find_naps(records) do
    {_current_guard, _nap_start_minute, guard_records} =
      Enum.reduce(records, {nil, nil, %{}}, fn {:ok, [{action, [datetime | other_data]}], "", _,
                                                _, _},
                                               {current_guard_id, nap_start_minute, guard_acc} ->
        case action do
          # Memoize current guard
          "begins_shift" ->
            # `other_data` because `rest` would be too punny.
            [id] = other_data

            {id, nil, guard_acc}

          # Memoize start time
          "falls_asleep" ->
            [_, _, _, _, minute] = datetime

            {current_guard_id, minute, guard_acc}

          # Sum minutes for current guard
          "wakes_up" ->
            [_, _, _, _, minute] = datetime

            minutes_slept =
              nap_start_minute..(minute - 1)
              |> Enum.into([])

            {
              current_guard_id,
              nil,
              Map.update(guard_acc, current_guard_id, [minutes_slept], &[minutes_slept | &1])
            }
        end
      end)

    guard_records
  end

  defp find_most_rested_guard(records) do
    records
    |> Enum.map(fn {guard_id, naps} -> {guard_id, List.flatten(naps)} end)
    |> Enum.max_by(fn {_, repose_log} -> Enum.sum(repose_log) end)
  end

  defp find_most_common_minute_asleep({guard_id, records}) do
    max =
      records
      |> Enum.group_by(& &1)
      |> Enum.max_by(fn {_, grouped_values} -> length(grouped_values) end)
      |> elem(0)

    {guard_id, max}
  end
end
