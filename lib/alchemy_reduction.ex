defmodule AlchemyReduction do
  @doc """
  Find the resulting polymer after opposite polarity reactions destroy each other.

  Example:

      iex> reduce_polymer("dabAcCaCBAcCcaDA")
      {:ok, "dabCBAcaDA", 10}

  """
  @spec reduce_polymer(String.t()) :: non_neg_integer()
  def reduce_polymer(input, polymer \\ [""], count \\ 0)

  def reduce_polymer(<<current::bytes-size(1), rest::binary>> = input, [last | polymer], count)
      when is_binary(input) do
    if current != last && String.upcase(current) == String.upcase(last) do
      reduce_polymer(rest, polymer, count - 1)
    else
      reduce_polymer(rest, [current, last | polymer], count + 1)
    end
  end

  def reduce_polymer("", polymer, count) do
    polymer =
      polymer
      |> Enum.reverse()
      |> Enum.join()

    {:ok, polymer, count}
  end
end
