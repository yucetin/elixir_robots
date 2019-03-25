defmodule MartiansRebooted do
  @moduledoc """
  Documentation for MartiansRebooted.
  """

  def run do
    input = read_input()

    %{grid: grid, robots: robots} = initialise(input)

    grid
    |> operate(robots)
    |> format_output()
    |> display()
  end

  def initialise([grid | robots]) do
    %{grid: build_grid(grid), robots: Enum.map(robots, &build_robot/1)}
  end

  def operate(grid, robots) do
    Enum.map(robots, fn robot -> run_actions(robot, grid) end)
  end

  def format_output(list_of_maps) do
    Enum.map(list_of_maps, fn %{x: x, y: y, bearing: bearing, alive: alive} ->
      format_output(x, y, bearing, alive)
    end)
  end

  defp display(stuff) do
    Enum.each(stuff, fn robot ->
      IO.puts(robot)
    end)
  end

  defp read_input do
    :grid |> read_input([]) |> Enum.reverse()
  end

  defp read_input(:grid, []) do
    grid = IO.gets("What are the dimensions of your grid?\ne.g. 0, 0\nor 5, 6\n")
    read_input(:ask, [grid])
  end

  defp read_input(:answer, ["n\n" | rest]), do: rest
  defp read_input(:answer, ["y\n" | rest]), do: read_input(:robot, rest)

  defp read_input(:ask, acc) do
    tell = IO.gets("Would you like to tell me about a(nother) robot? (y/n)\n")
    read_input(:answer, [tell | acc])
  end

  defp read_input(:robot, acc) do
    robot =
      IO.gets(
        "Tell me about your robot initial state and actions?\ne.g.\n (0, 0, N) FFF\n(1, 4, S) LFFRFL\n"
      )

    read_input(:ask, [robot | acc])
  end

  defp format_output(x, y, bearing, alive) do
    lost = if alive, do: "", else: " LOST"
    "(#{Integer.to_string(x)}, #{Integer.to_string(y)}, #{Atom.to_string(bearing)})#{lost}"
  end

  defp build_grid(grid) do
    [x, y] =
      grid
      |> String.replace(",", "")
      |> String.replace("\n", "")
      |> String.split(" ")
      |> Enum.map(fn x -> String.to_integer(x) end)

    %{x: x, y: y}
  end

  defp build_robot(string) do
    [x, y, bearing, actions] =
      Regex.run(~r|(\d), (\d), (\D)\) ([^\n]+)|, string, capture: :all_but_first)

    %{
      x: String.to_integer(x),
      y: String.to_integer(y),
      bearing: String.to_atom(bearing),
      actions: actions_splitter(actions),
      alive: true
    }
  end

  defp actions_splitter(actions) do
    actions
    |> String.graphemes()
    |> Enum.map(fn x -> String.to_atom(x) end)
  end

  defp run_actions(robot, grid) do
    run_actions(robot.actions, robot, grid)
  end

  defp run_actions([], robot, _grid), do: robot
  defp run_actions(_actions, %{alive: false} = robot, _grid), do: robot

  defp run_actions([action | actions], robot, grid) do
    robot = run_action(action, robot, grid)
    run_actions(actions, robot, grid)
  end

  defp run_action(action, robot, grid) do
    bearing = turn(action, robot.bearing)
    {x, y, alive} = advance(action, robot, grid)
    %{x: x, y: y, alive: alive, bearing: bearing}
  end

  defp advance(:F, %{bearing: :N, x: x, y: y}, %{y: grid_y}) do
    if y == grid_y do
      {x, y, false}
    else
      {x, y + 1, true}
    end
  end

  defp advance(:F, %{bearing: :E, x: x, y: y}, %{x: grid_x}) do
    if x == grid_x do
      {x, y, false}
    else
      {x + 1, y, true}
    end
  end

  defp advance(:F, %{bearing: :W, x: x, y: y}, _) do
    if x == 0 do
      {x, y, false}
    else
      {x - 1, y, true}
    end
  end

  defp advance(:F, %{bearing: :S, x: x, y: y}, _) do
    if within?() do
      {x, y, false}
    else
      {x, y - 1, true}
    end
  end

  def within?(%{bearing: :N, x: x, y: y}, %{y: grid_y, %{x: grid_x) do
    0 <= x and x < grid_x and 0 <= y and y < grid_y
  end

  defp advance(_, %{x: x, y: y, alive: alive}, _), do: {x, y, alive}

  defp turn(:L, :N), do: :W
  defp turn(:L, :W), do: :S
  defp turn(:L, :S), do: :E
  defp turn(:L, :E), do: :N

  defp turn(:R, :N), do: :E
  defp turn(:R, :W), do: :N
  defp turn(:R, :S), do: :E
  defp turn(:R, :E), do: :S

  defp turn(:F, bearing), do: bearing
end
