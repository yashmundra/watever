defmodule AssertionTest do
  # 3) Notice we pass "async: true", this runs the test case
  #    concurrently with other test cases. The individual tests
  #    within each test case are still run serially.
  # 4) Use the "test" macro instead of "def" for clarity.
  use ExUnit.Case, async: true

  test "the truth" do
    assert true
  end

  test "actual test" do
    userName = Integer.to_string(count)
    noOfTweets = no_of_messages
    noToSubscribe = 2
    pid = spawn(fn -> TwitterClone.Client.start_link(userName,noOfTweets,noToSubscribe,false) end)
    :ets.insert(:mainregistry, {userName, pid})
  end

  
end
