defmodule Day11 do
  @input 7689
  @max_size 300

  def main do
    sum_area_table =
      (for x <- 1..@max_size, y <- 1..@max_size, do: {x, y})
      |> Enum.reduce(%{}, &Map.put(&2, &1, power(&1)))
      |> create_sat

    IO.puts(header() <> part_1(sum_area_table) <> "\n")

    IO.puts("Part 2: " <> part_2(sum_area_table) <> "\n")
  end

  # Largest 3x3 power grid
  def part_1(sum_area_table) do
    {x, y} =
      scan_all(sum_area_table, 3)
      |> Map.get(:pos)

    Enum.map([x, y], &Integer.to_string/1)
    |> Enum.join(",")
  end

  # Largest grid of any dimension
  def part_2(sum_area_table, size \\ 1, best \\ %{val: -99999, pos: nil, size: 0})
  def part_2(_sum_area_table, size, best) when size > @max_size do
    {x, y} = best.pos

    Enum.map([x, y, best.size], &Integer.to_string/1)
    |> Enum.join(",")
  end
  def part_2(sum_area_table, size, best) do
    result = scan_all(sum_area_table, size)
    new_best =
      if result.val > best.val do
        %{val: result.val, pos: result.pos, size: size}
      else
        best
      end

    part_2(sum_area_table, size + 1, new_best)
  end

  # Checks the sum of every possible square of a given size, returns the highest
  defp scan_all(sat, size, x \\ 1, y \\ 1, best \\ %{val: -99999, pos: nil})
  defp scan_all(_sat, size, _x, y, best) when y > @max_size - size + 1, do: best
  defp scan_all(sat, size, x, y, best) when x > @max_size - size + 1 do
    scan_all(sat, size, 1, y + 1, best)
  end
  defp scan_all(sat, size, x, y, best) do
    p = calculate(sat, x, y, size)
    new_best = if p > best.val do %{val: p, pos: {x, y}} else best end

    scan_all(sat, size, x + 1, y, new_best)
  end

  # Quickly calculates the sum of power levels using the summed-area table
  defp calculate(sat, x, y, size) do
    a = Map.get(sat, {x - 1, y - 1}, 0)
    f_1 = Map.get(sat, {x - 1, y + size - 1}, 0)
    f_2 = Map.get(sat, {x + size - 1, y - 1}, 0)
    m = Map.get(sat, {x + size - 1, y + size - 1}, 0)

    m - f_1 - f_2 + a
  end

  # Summed-area table created with one pass over the grid
  def create_sat(grid, x \\ 1, y \\ 1, done \\ %{})
  def create_sat(_grid, _x, y, done) when y > @max_size, do: done
  def create_sat(grid, x, y, done) when x > @max_size, do: create_sat(grid, 1, y+1, done)
  def create_sat(grid, x, y, done) do
    val =
      grid[{x, y}] + Map.get(done, {x, y-1}, 0) + Map.get(done, {x-1, y}, 0) -
        Map.get(done, {x-1, y-1}, 0)

    create_sat(grid, x + 1, y, Map.put(done, {x, y}, val))
  end

  # This formula is provided in the puzzle description for determining the power level of a cell
  def power({x, y}), do: h_digit(x*x*y + 20*x*y + 100*y + @input*x + @input*10) - 5

  # Returns the "hundreds" digit of a number
  def h_digit(n) do
    case String.at(Integer.to_string(n), -3) do
      nil -> 0
      num -> num
    end
    |> String.to_integer
  end

  defp header do
    "\n***********************\nADVENT OF CODE - DAY 11" <>
      "\n***********************\n\nPart 1: "
  end
end

Day11.main()
