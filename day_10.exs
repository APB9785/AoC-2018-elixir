defmodule Day10 do
  @boundaries %{min_x: 99999, max_x: -99999, min_y: 99999, max_y: -99999}

  def main do
    header() |> IO.puts

    {result, timer} = parse_input() |> run_simulation

    IO.puts(display(result) <> "\nPart 2: " <> timer <> "\n")
  end

  # Converts the input to a list of tuples of tuples of integers
  # i.e. IO -> [{{x, y}, {i, j}}]
  def parse_input do
    f = File.read!("day10input.txt")
    r = ~r/position=< *(-?\d+), *(-?\d+)> velocity=< *(-?\d+), *(-?\d+)>/

    Regex.scan(r, f)
    |> Enum.map(fn match ->
         [px, py, vx, vy] = Enum.map(tl(match), &String.to_integer/1)
         {{px, py}, {vx, vy}}
       end)
  end

  # Runs until convergence, returns end state {particles, bounds, timer}
  def run_simulation(particles, last_spread \\ 999999, timer \\ 0)
  def run_simulation(particles, last_spread, timer) do
    new_particles = step(particles)
    new_bounds = analyze(new_particles)

    case new_bounds.max_y - new_bounds.min_y do
      new_spread when new_spread > last_spread ->
        {{particles, analyze(particles)}, Integer.to_string(timer)}
      new_spread ->
        run_simulation(new_particles, new_spread, timer + 1)
    end
  end

  # Apply velocity to each particle
  defp step(particles) do
    Enum.map(particles,
      fn {{px, py}, {vx, vy}} ->
        {{px+vx, py+vy}, {vx, vy}}
      end)
  end

  # Shows a view of the particles at the convergence point
  defp display({particles, bounds}) do

    # Create a buffer around the area for nicer display
    bounds =
      bounds
      |> Map.update!(:min_x, &(&1 - 1))
      |> Map.update!(:max_x, &(&1 + 1))
      |> Map.update!(:min_y, &(&1 - 1))
      |> Map.update!(:max_y, &(&1 + 1))

    # Convert the particle coords to a MapSet for O(1) membership checking
    Enum.reduce(particles, MapSet.new(), &MapSet.put(&2, elem(&1, 0)))
    |> make_string(bounds.min_x, bounds.min_y, bounds)
  end

  # This constructs the view of particles as a string for terminal output
  defp make_string(coords, x, y, bounds, done \\ [])
  defp make_string(coords, x, y, bounds, done) do
    cond do
      y > bounds.max_y ->
        done |> Enum.reverse |> Enum.join
      x > bounds.max_x ->
        make_string(coords, bounds.min_x, y + 1, bounds, ["\n" | done])
      MapSet.member?(coords, {x, y}) ->
        make_string(coords, x + 1, y, bounds, ["#" | done])
      true ->
        make_string(coords, x + 1, y, bounds, ["." | done])
    end
  end

  # Goes through the list of particles to find min and max values
  defp analyze(particles, bounds \\ @boundaries)
  defp analyze([], bounds), do: bounds
  defp analyze([{{x, y}, _} | t], bounds) do
    new_bounds =
      bounds
      |> Map.update!(:min_x, &min(&1, x))
      |> Map.update!(:max_x, &max(&1, x))
      |> Map.update!(:min_y, &min(&1, y))
      |> Map.update!(:max_y, &max(&1, y))

    analyze(t, new_bounds)
  end

  defp header do
    "\n***********************\nADVENT OF CODE - DAY 10" <>
      "\n***********************\n\nPart 1: "
  end
end

Day10.main()
