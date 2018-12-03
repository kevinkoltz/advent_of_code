defmodule InventoryManagementSystem do
  @doc """
  Calculate a checksum for a given list of box IDs. Counts the number of times a letter appears
  twice, then multiplies by the number of times a letter appears 3 times.

  Example:

      iex> calculate_checksum(~w(abcdef bababc abbcde abcccd aabcdd abcdee ababab))
      12

  """
  @spec calculate_checksum([String.t()], non_neg_integer(), non_neg_integer()) ::
          non_neg_integer()
  def calculate_checksum(box_ids, twos \\ 0, threes \\ 0)
  def calculate_checksum([], twos, threes), do: twos * threes

  def calculate_checksum([box_id | rest], twos, threes) do
    letter_counts = count_letters(box_id)

    two = if 2 in letter_counts, do: 1, else: 0
    three = if 3 in letter_counts, do: 1, else: 0

    calculate_checksum(rest, twos + two, threes + three)
  end

  @spec count_letters(String.t()) :: [non_neg_integer()]
  defp count_letters(string) when is_binary(string) do
    string
    |> String.codepoints()
    |> Enum.reduce(%{}, fn letter, acc ->
      Map.update(acc, letter, 1, &(&1 + 1))
    end)
    |> Map.values()
  end

  @doc """
  Finds a pair of boxes which differ by one character in their box ID at the same position.

  Returns the common characters between the two boxes.

  Example:

      iex> find_fabric_prototype_boxes(~w(abcde fghij klmno pqrst fguij axcye wvxyz))
      "fgij"

      iex> find_fabric_prototype_boxes(~w(abc bbc))
      "bc"

      iex> find_fabric_prototype_boxes(~w(abc abd))
      "ab"

  """
  @spec find_fabric_prototype_boxes([String.t()]) :: String.t()
  def find_fabric_prototype_boxes(box_ids) do
    Enum.reduce_while(box_ids, nil, fn box_id_1, _ ->
      list_1 = String.codepoints(box_id_1)

      found =
        Enum.reduce_while(box_ids, nil, fn box_id_2, _ ->
          list_2 = String.codepoints(box_id_2)

          case List.myers_difference(list_1, list_2) do
            [eq: lhs, del: [_], ins: [_], eq: rhs] -> {:halt, Enum.join(lhs) <> Enum.join(rhs)}
            [eq: lhs, del: [_], ins: [_]] -> {:halt, Enum.join(lhs)}
            [del: [_], ins: [_], eq: rhs] -> {:halt, Enum.join(rhs)}
            _ -> {:cont, nil}
          end
        end)

      case found do
        nil -> {:cont, nil}
        found -> {:halt, found}
      end
    end)
  end
end
