defmodule AssertionTest do
  # 3) Notice we pass "async: true", this runs the test case
  #    concurrently with other test cases. The individual tests
  #    within each test case are still run serially.
  use ExUnit.Case, async: true

  # 4) Use the "test" macro instead of "def" for clarity.
  test "the truth" do
    assert true
  end
end
