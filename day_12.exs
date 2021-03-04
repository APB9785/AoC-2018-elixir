defmodule Day12 do
  def main do
    input = parse_input()

    IO.puts(header() <> part_1(input) <> "\n")

    IO.puts("Part 2: " <> part_2(input) <> "\n")
  end

  # Sum of active cell indices after 20 generations
  defp part_1(input) do
    input
    |> loop_for(20)
    |> sum_active_cell_indices
    |> Integer.to_string
  end

  # Sum of active cell indices after 50,000,000,000 generations.
  # This is made possible by only running the simulation until growth converges
  # to a constant rate, then using simple math to calculate the rest.
  defp part_2({state, rules, bounds}) do
    conv = find_convergence(state, rules, bounds)

    (50000000000 - conv.generations) * conv.sum_step + conv.sum
    |> Integer.to_string
  end

  # Convert the input into a tuple of three maps: {state, rules, bounds}
  defp parse_input do
    ["initial state: " <> state_string, rules_string] =
      File.read!("day12input.txt")
      |> String.split("\n\n")

    rules_map =
      rules_string
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn x, acc ->
           [condition, result] = String.split(x, " => ")
           Map.put(acc, condition, result)
         end)

    state_map =
      state_string
      |> String.graphemes
      |> Enum.reduce(%{}, &map_by_index/2)

    bounds = %{min: 0, max: map_size(state_map) - 1}

    {state_map, rules_map, bounds}
  end

  # In Part 1 we are asked to simulate running the automaton x times
  defp loop_for({state, _, _}, 0), do: state
  defp loop_for({state, rules, bounds}, count) do
    next_gen(state, rules, bounds) |> loop_for(count - 1)
  end

  # For Part 2 we need to find a convergence point where growth becomes constant
  defp find_convergence(state, rules, bounds, history \\ [0, 1, 1], count \\ 0)
  defp find_convergence(state, rules, bounds, history, count) do
    {next_state, rules, new_bounds} = next_gen(state, rules, bounds)

    current_sum = sum_active_cell_indices(next_state)

    [pre | [p_2 | [p_3 | _rest]]] = history

    if p_2 - p_3 == pre - p_2 and pre - p_2 == current_sum - pre do
      %{
        state: state,
        sum: current_sum,
        sum_step: current_sum - pre,
        generations: count + 1
      }
    else
      find_convergence(next_state, rules, new_bounds, [current_sum | history], count + 1)
    end
  end

  # Here is the logic for advancing the simulation by one generation
  defp next_gen(state, rules, bounds) do
    left = rules[check_neighbors(state, bounds.min - 1)]
    right = rules[check_neighbors(state, bounds.max + 1)]

    new_state =
      Range.new(bounds.min, bounds.max)
      |> Enum.reduce(%{}, fn x, acc ->
           neighbors = check_neighbors(state, x)
           Map.put(acc, x, rules[neighbors])
         end)
      |> Map.put(bounds.min - 1, if left == "#" do "#" else "." end)
      |> Map.put(bounds.max + 1, if right == "#" do "#" else "." end)

    new_bounds =
      %{
        min: if left == "#" do bounds.min - 1 else bounds.min end,
        max: if right == "#" do bounds.max + 1 else bounds.max end
      }

    {new_state, rules, new_bounds}
  end

  # Return a string of current cell and two nearest neighbors on both sides
  defp check_neighbors(state, index) do
    Range.new(-2, 2)
    |> Enum.reduce([], fn x, acc -> [Map.get(state, index + x, ".") | acc] end)
    |> Enum.reverse
    |> Enum.join
  end

  defp sum_active_cell_indices(state) do
    Enum.reduce(state, 0, fn {k, v}, acc ->
      if v == "#" do acc + k else acc end
    end)
  end

  defp map_by_index(x, acc), do: Map.put(acc, map_size(acc), x)

  defp header do
    "\n***********************\nADVENT OF CODE - DAY 12" <>
      "\n***********************\n\nPart 1: "
  end
end

Day12.main()
