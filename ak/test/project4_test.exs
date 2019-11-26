defmodule AssertionTest do
  # 3) Notice we pass "async: true", this runs the test case
  #    concurrently with other test cases. The individual tests
  #    within each test case are still run serially.
  # 4) Use the "test" macro instead of "def" for clarity.
  use ExUnit.Case

  test "the truth" do
    assert true
  end

  test "Registering User" do
    Task.async fn -> TwitterClone.Server.start_link() end
    :timer.sleep(3000)

    send(:global.whereis_name(:TwitterServer),{:registerUser,1,self()})
    receive do
        {:registerConfirmation} -> assert true
    end
  end

  test "tweeting and retrieving tweets" do
    pid = Task.async fn -> TwitterClone.Server.start_link() end
    :timer.sleep(3000)

    send(:global.whereis_name(:TwitterServer),{:registerUser,1,self()})

    send(:global.whereis_name(:TwitterServer),{:tweet,"how di do #fr",1})

    send(:global.whereis_name(:TwitterServer),{:getMyTweets,1})    

    receive do
      {:repGetMyTweets,list} -> IO.inspect "all my tweets are #{list}"
    end
    
  end


  # # test "my mentions" do

  # #   Task.async fn -> TwitterClone.Server.start_link() end
  # #   :timer.sleep(3000)

  # #   send(:global.whereis_name(:TwitterServer),{:registerUser,1,self()})
  # #   send(:global.whereis_name(:TwitterServer),{:registerUser,2,self()})
  # #   send(:global.whereis_name(:TwitterServer),{:tweet,"user 1 tweeting that #COP5615isgreat @2",1})
    
  # #   send(:global.whereis_name(:TwitterServer),{:tweetsWithMention,2})
  # #   receive do
  # #       {:repTweetsWithMention,list} -> IO.inspect list, label: "User 2 :- Tweets With @2"
  # #   end

  # # end

  # test "subscribe to people" do
  #   Task.async fn -> TwitterClone.Server.start_link() end
  #   :timer.sleep(3000)

  #   send(:global.whereis_name(:TwitterServer),{:registerUser,1,self()})
  #   send(:global.whereis_name(:TwitterServer),{:registerUser,2,self()})

  #   send(:global.whereis_name(:TwitterServer),{:addSubscriber,1,"2"})


    
  # end

  # test "tweets subscribed" do

  #   Task.async fn -> TwitterClone.Server.start_link() end
  #   :timer.sleep(3000)
    
  #   send(:global.whereis_name(:TwitterServer),{:registerUser,1,self()})
  #   send(:global.whereis_name(:TwitterServer),{:registerUser,2,self()})

  #   send(:global.whereis_name(:TwitterServer),{:tweet,"user 1 tweeting that #COP5615isgreat",2})

  #   send(:global.whereis_name(:TwitterServer),{:addSubscriber,1,"2"})


  #   send(:global.whereis_name(:TwitterServer),{:tweetsSubscribedTo,1})
  #   receive do
  #       {:repTweetsSubscribedTo,list} ->  IO.inspect list, label: "User1 :- Tweets Subscribed To"
  #   end

  # end
  
end
