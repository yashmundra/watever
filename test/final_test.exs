defmodule FinalTest do
  use ExUnit.Case
  doctest Final

  test "greets the world" do
    assert Final.hello() == :world
  end
end
