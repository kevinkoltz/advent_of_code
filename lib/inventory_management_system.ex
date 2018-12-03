defmodule InventoryManagementSystem do
  @doc """
  Calculate a checksum for a given list of box IDs. Counts the number of times a letter appears
  twice, then multiplies by the number of times a letter appears 3 times.

  Example:

      iex> calculate_checksum(~w(abcdef bababc abbcde abcccd aabcdd abcdee ababab))
      12

  """
  @spec calculate_checksum([String.t()]) :: non_neg_integer()
  def calculate_checksum(box_ids) when is_list(box_ids) do
    increment_occurrences_if_present = fn acc, values, value ->
      if value in values do
        add_occurrence(value, acc)
      else
        acc
      end
    end

    occurrences =
      box_ids
      |> Enum.map(&count_letters/1)
      |> Enum.map(&uniq_map_values/1)
      |> Enum.reduce(%{2 => 0, 3 => 0}, fn values, acc ->
        acc
        |> increment_occurrences_if_present.(values, 2)
        |> increment_occurrences_if_present.(values, 3)
      end)

    occurrences[2] * occurrences[3]
  end

  @doc """
  Finds a pair of boxes which differ by one character in their box ID at the same position.

  Returns the common characters between the two boxes.

  Example:

      iex> find_fabric_prototype_boxes(~w(abcde fghij klmno pqrst fguij axcye wvxyz))
      "fgij"

  """
  @spec find_fabric_prototype_boxes([String.t()]) :: String.t()
  def find_fabric_prototype_boxes(box_ids) do
    Enum.reduce_while(box_ids, nil, fn box_id_1, _ ->
      list_1 = String.codepoints(box_id_1)

      found =
        Enum.reduce_while(box_ids, nil, fn box_id_2, _ ->
          list_2 = String.codepoints(box_id_2)

          case List.myers_difference(list_1, list_2) do
            [eq: lhs, del: [_], ins: [_], eq: rhs] ->
              {:halt, Enum.join(lhs) <> Enum.join(rhs)}

            _ ->
              {:cont, nil}
          end
        end)

      case found do
        nil -> {:cont, nil}
        found -> {:halt, found}
      end
    end)
  end

  @spec count_letters(String.t()) :: map()
  defp count_letters(box_id) do
    box_id
    |> String.graphemes()
    |> Enum.reduce(%{}, &add_occurrence/2)
  end

  @spec uniq_map_values(map()) :: [non_neg_integer()]
  def uniq_map_values(map) do
    map
    |> Map.values()
    |> Enum.uniq()
  end

  defp add_occurrence(value, acc) do
    Map.update(acc, value, 1, &(&1 + 1))
  end
end
