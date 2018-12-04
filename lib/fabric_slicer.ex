defmodule FabricSlicer do
  defmodule Claim do
    @moduledoc """
    Dimensions and position for a cutout on fabric, offset in inches.
    """
    defstruct id: nil, height: nil, width: nil, offset_top: nil, offset_left: nil

    @type t :: %__MODULE__{
            id: non_neg_integer(),
            height: non_neg_integer(),
            width: non_neg_integer(),
            offset_top: non_neg_integer(),
            offset_left: non_neg_integer()
          }

    @doc """
    Parses a claim specification.

    Example:

        iex> parse("#123 @ 3,2: 5x4")
        %Claim{height: 4, width: 5, offset_left: 3, offset_top: 2, id: 123}

    """
    @spec parse(String.t()) :: t()
    def parse(claim_text) when is_binary(claim_text) do
      Regex.split(~r/[^0-9]/, claim_text)
      |> Enum.filter(fn
        "" -> false
        _ -> true
      end)
      |> Enum.map(&String.to_integer/1)
      |> do_parse()
    end

    defp do_parse([id, offset_left, offset_top, width, height]) do
      %__MODULE__{
        id: id,
        offset_left: offset_left,
        offset_top: offset_top,
        width: width,
        height: height
      }
    end

    @doc """
    Converts a claim to a list of points for fabric.
    """
    def to_points(%Claim{
          height: height,
          width: width,
          offset_top: offset_top,
          offset_left: offset_left
        }) do
      for x <- 1..width, y <- 1..height do
        {offset_left + x, offset_top + y}
      end
    end

    def to_points_with_id(%Claim{
          id: id,
          height: height,
          width: width,
          offset_top: offset_top,
          offset_left: offset_left
        }) do
      for x <- 1..width, y <- 1..height do
        {offset_left + x, offset_top + y, id}
      end
    end
  end

  defmodule Fabric do
    defstruct points: nil, height: nil, width: nil

    @type point :: {x :: non_neg_integer(), y :: non_neg_integer()}
    @type t :: %__MODULE__{
            points: %{point => overlap_count :: non_neg_integer()},
            height: non_neg_integer(),
            width: non_neg_integer()
          }

    @spec new(non_neg_integer(), non_neg_integer()) :: t()
    def new(height, width) do
      points = for x <- 1..width, y <- 1..height, into: %{}, do: {{x, y}, 0}
      %__MODULE__{points: points, height: height, width: width}
    end

    @spec new(t(), [point]) :: t()
    def seed(%Fabric{} = fabric, new_points) do
      %{
        fabric
        | points:
            new_points
            |> Enum.reduce(fabric.points, fn point, acc ->
              overlap_count = acc[point] + 1
              %{acc | point => overlap_count}
            end)
      }
    end

    @spec sum_overlaps(t()) :: non_neg_integer()
    def sum_overlaps(%Fabric{points: points}) do
      points
      |> Enum.map(fn
        {_, overlap_count} when overlap_count < 2 -> 0
        _ -> 1
      end)
      |> Enum.sum()
    end

    @spec print(t()) :: t()
    def print(%Fabric{points: points, height: height, width: width} = fabric) do
      Enum.map(1..height, fn y ->
        Enum.map(1..width, fn x ->
          case points[{x, y}] do
            overlap when overlap > 1 -> Integer.to_string(overlap)
            overlap when overlap == 1 -> "#"
            _ -> "."
          end
        end)
      end)
      |> Enum.join("\n")
      |> IO.puts()

      fabric
    end
  end

  @doc """
  Calculates overused fabric in square inches based on plans that overlap.

  Example:

      iex> calculate_overused_fabric(["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"], 10, 10)
      4

  """
  @spec calculate_overused_fabric([String.t()], non_neg_integer(), non_neg_integer()) ::
          non_neg_integer()
  def calculate_overused_fabric([], _height, _width), do: 0

  def calculate_overused_fabric(claims, height, width) when is_list(claims) do
    points =
      claims
      |> Enum.map(&Claim.parse/1)
      |> Enum.map(&Claim.to_points/1)
      |> List.flatten()

    fabric = Fabric.new(height, width)

    fabric
    |> Fabric.seed(points)
    |> Fabric.sum_overlaps()
  end

  @doc """
  Calculates overused fabric in square inches based on plans that overlap.

  This should be refactored to be simpler and possibly use the
  [edges overlap algorithm](https://www.geeksforgeeks.org/find-two-rectangles-overlap/),
  but need sleep for now.

  Example:

      iex> find_non_overlapping_claim(["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"])
      3

  """
  @spec find_non_overlapping_claim([String.t()]) :: Claim.t()
  def find_non_overlapping_claim([]), do: 0

  def find_non_overlapping_claim(claims) when is_list(claims) do
    ids =
      claims
      |> Enum.map(&Claim.parse/1)
      |> Enum.map(&Claim.to_points_with_id/1)
      |> List.flatten()
      |> Enum.group_by(fn {x, y, _} -> {x, y} end, fn {_, _, id} -> id end)
      |> Enum.reduce(%{non_overlaps: MapSet.new(), overlaps: MapSet.new()}, fn
        {_, [id]}, acc ->
          %{acc | non_overlaps: MapSet.put(acc.non_overlaps, id)}

        {_, ids}, acc ->
          overlaps =
            Enum.reduce(ids, acc.overlaps, fn id, acc ->
              MapSet.put(acc, id)
            end)

          %{acc | overlaps: overlaps}
      end)

    [non_overlapping_id] =
      ids.non_overlaps
      |> MapSet.difference(ids.overlaps)
      |> MapSet.to_list()

    non_overlapping_id
  end
end
