defmodule MartiansRebootedTest do
  use ExUnit.Case
  doctest MartiansRebooted

  describe "run" do
    @tag :skip
    test "simple stay alive case, moving only forward" do
      robots = MartiansRebooted.run("2 2\n(0, 0, N) F\n")
      assert robots == "(0, 1, N)\n"
    end
  end

  describe "initialise" do
    test "with multiple robots" do
      assert MartiansRebooted.initialise(["5, 6\n", "(0, 0, N) FFF\n", "(5, 6, S) RFLF\n"]) ==
               %{
                 grid: %{x: 5, y: 6},
                 robots: [
                   %{alive: true, bearing: :N, x: 0, y: 0, actions: [:F, :F, :F]},
                   %{alive: true, bearing: :S, x: 5, y: 6, actions: [:R, :F, :L, :F]}
                 ]
               }
    end
  end

  describe "operate" do
    test "with one robot that stays alive" do
      assert MartiansRebooted.operate(
               %{x: 2, y: 2},
               [%{alive: true, bearing: :N, x: 0, y: 0, actions: [:F]}]
             ) == [%{alive: true, bearing: :N, x: 0, y: 1}]
    end

    test "with one robot that moves West" do
      assert MartiansRebooted.operate(
               %{x: 2, y: 2},
               [%{alive: true, bearing: :W, x: 1, y: 0, actions: [:F]}]
             ) == [%{alive: true, bearing: :W, x: 0, y: 0}]
    end

    test "with one robot that moves West to die" do
      assert MartiansRebooted.operate(
               %{x: 2, y: 2},
               [%{alive: true, bearing: :W, x: 1, y: 0, actions: [:F, :F]}]
             ) == [%{alive: false, bearing: :W, x: 0, y: 0}]
    end

    test "with one robot that moves South to die" do
      assert MartiansRebooted.operate(
               %{x: 2, y: 2},
               [%{alive: true, bearing: :S, x: 1, y: 1, actions: [:F, :F]}]
             ) == [%{alive: false, bearing: :S, x: 1, y: 0}]
    end

    test "with one robot that moves South to live" do
      assert MartiansRebooted.operate(
               %{x: 2, y: 2},
               [%{alive: true, bearing: :S, x: 1, y: 1, actions: [:F]}]
             ) == [%{alive: true, bearing: :S, x: 1, y: 0}]
    end

    test "turning right" do
      assert MartiansRebooted.operate(
               %{x: 2, y: 2},
               [%{alive: true, bearing: :S, x: 1, y: 1, actions: [:L]}]
             ) == [%{alive: true, bearing: :E, x: 1, y: 1}]
    end
  end

  describe "format_output" do
    test "for multiple robots" do
      assert MartiansRebooted.format_output([
               %{alive: true, bearing: :S, x: 3, y: 4},
               %{alive: false, bearing: :E, x: 5, y: 2}
             ]) == ["(3, 4, S)", "(5, 2, E) LOST"]
    end
  end
end
