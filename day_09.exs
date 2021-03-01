defmodule Day9 do
  def run do
    part_1 = parse_input() |> play

    IO.puts(header() <> get_top_score(part_1))

    # Continue playing the game 99 more times
    part_2 = part_1 |> Map.update!(:final_marble, &(&1 * 100)) |> play

    IO.puts("\nPart 2: " <> get_top_score(part_2) <> "\n")
  end

  defp parse_input do
    f = File.read!("day9input.txt")
    [_full_match, player_count, final_marble_score] =
      Regex.run(~r/([0-9]+) players; last marble is worth ([0-9]+) points/, f)
    player_count = String.to_integer(player_count)

    %{
      player_count: player_count,
      active_player: 3,
      player_scores: Enum.reduce(1..player_count, %{}, &Map.put(&2, &1, 0)),
      next_marble: 3,
      circle: {[0], [2, 1]},
      final_marble: String.to_integer(final_marble_score)
    }
  end

  # End of game
  defp play(%{:next_marble => n, :final_marble => f} = state) when n > f do
    state
  end
  # Scoring turn - remove a marble
  defp play(%{:next_marble => x} = state) when rem(x, 23) == 0 do
    state
    |> score_turn
    |> pass_turn
    |> play
  end
  # Standard turn - add a marble
  defp play(state) do
    state
    |> Map.update!(:circle, &add_marble(&1, state.next_marble))
    |> pass_turn
    |> play
  end

  # Update the circle when a new marble is added.
  defp add_marble(circle, new_marble) when new_marble < 20 do
    circle
    |> small_rotate
    |> put(new_marble)
    |> small_rotate
  end
  defp add_marble(circle, new_marble) do
    circle
    |> rotate
    |> put(new_marble)
    |> rotate
  end

  # Logic for updating the circle and score when a scoring turn happens
  defp score_turn(state) do
    # First rotate ccw 7 times
    state =
      Map.update!(state, :circle,
        &Enum.reduce(1..7, &1, fn _x, acc -> lrotate(acc) end))

    # Add the score to the current player and remove the current marble
    state
    |> Map.update!(:player_scores,
         &Map.update!(&1, state.active_player, fn score ->
           score + state.next_marble + hd(elem(state.circle, 1)) end))
    |> Map.update!(:circle, &remove/1)
  end

  # Generic functions to run at the end of every turn
  defp pass_turn(state) do
    state
    |> Map.update!(:active_player, &next_player(&1, state.player_count))
    |> Map.update!(:next_marble, &(&1 + 1))
  end

  # Prepare the top score for printing to console
  defp get_top_score(state) do
    state
    |> Map.get(:player_scores)
    |> Map.values
    |> Enum.max
    |> Integer.to_string
  end

  # Rotate clockwise - if the end of the list is reached, the pre list wraps
  # around.  The first 7 marbles are kept in the pre list as a buffer in case
  # the next marble is a scoring marble.
  defp rotate({pre, [curr]}) do
    {Enum.take([curr | pre], 7), Enum.reverse(Enum.drop([curr | pre], 7))}
  end
  defp rotate({pre, [curr | rest]}), do: {[curr | pre], rest}

  # Small rotation works just like regular rotation, but if it gets to the end
  # of the list and needs to wrap around, it wraps the entire list, not leaving
  # a buffer in the pre list. (Prevents a possible bug if the list is small)
  defp small_rotate({pre, [curr]}), do: {[curr], Enum.reverse(pre)}
  defp small_rotate({pre, [curr | rest]}), do: {[curr | pre], rest}

  # Rotate counter-clockwise
  defp lrotate({[pre | rest], curr}), do: {rest, [pre | curr]}

  # Put the new marble in its appropriate place
  defp put({pre, [curr | rest]}, new), do: {pre, [curr | [new | rest]]}

  # Remove the current marble
  defp remove({pre, [_curr | rest]}), do: {pre, rest}

  # Modular arithmetic for keeping track of the active player
  defp next_player(id, total), do: rem(id, total) + 1

  defp header do
    "\n**********************\nADVENT OF CODE - DAY 9" <>
      "\n**********************\n\nPart 1: "
  end
end

Day9.run()
