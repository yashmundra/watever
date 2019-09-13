defmodule MyprojectTest do
  use ExUnit.Case
  doctest Myproject

  test "greets the world" do
    assert Myproject.hello() == :world
  end
end
