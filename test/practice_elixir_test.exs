defmodule PracticeElixirTest do
  use ExUnit.Case
  doctest PracticeElixir

  test "greets the world" do
    assert PracticeElixir.hello() == :world
  end
end
