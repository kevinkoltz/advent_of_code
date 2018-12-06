defmodule AlchemyReduction do
  @doc """
  Find the resulting polymer after opposite polarity reactions destroy each other.

  Example:

      iex> reduce_polymer("dabAcCaCBAcCcaDA")
      {:ok, "dabCBAcaDA", 10}

  """
  @spec reduce_polymer(String.t()) :: non_neg_integer()
  def reduce_polymer(input, polymers \\ [""], count \\ 0)

  def reduce_polymer(<<current::bytes-size(1), rest::binary>> = input, [last | polymers], count)
      when is_binary(input) do
    if is_reaction?(current, last) do
      reduce_polymer(rest, polymers, count - 1)
    else
      reduce_polymer(rest, [current, last | polymers], count + 1)
    end
  end

  def reduce_polymer("", polymers, count) do
    polymer_chemical_composition =
      polymers
      |> Enum.reverse()
      |> Enum.join()

    {:ok, polymer_chemical_composition, count}
  end

  defp is_reaction?(a, b) when a != b, do: String.upcase(a) == String.upcase(b)
  defp is_reaction?(_, _), do: false
end
