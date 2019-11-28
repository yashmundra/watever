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
    Task.async fn -> Twitter_Server.start_link() end
    :timer.sleep(3000)

    send(:global.whereis_name(:TwitterServer),{:user_register,1,self()})
    receive do
        {:registerConfirmation} -> assert true
    end
  end

  test "tweeting tweets" do
    Task.async fn -> Twitter_Server.start_link() end
    :timer.sleep(3000)

    send(:global.whereis_name(:TwitterServer),{:user_register,1,self()})

    send(:global.whereis_name(:TwitterServer),{:tweet,"how di do #fr",1})

    :timer.sleep(500)

    [{_,[tweet]}] = :ets.lookup(:tweets, 1)

    assert tweet=="how di do #fr"
    
  end

  test "retreiving tweets" do
    Task.async fn -> Twitter_Server.start_link() end
    :timer.sleep(3000)

    send(:global.whereis_name(:TwitterServer),{:user_register,1,self()})

    send(:global.whereis_name(:TwitterServer),{:tweet,"how di do #fr",1})

    send(:global.whereis_name(:TwitterServer),{:getMyTweets,1})    

    receive do
       {:repGetMyTweets,[list]} -> assert list=="how di do #fr"
     end

    
  end

  test "get subscribed tweets" do

    Task.async fn -> Twitter_Server.start_link() end
    :timer.sleep(3000)

    send(:global.whereis_name(:TwitterServer),{:user_register,2,self()})

    send(:global.whereis_name(:TwitterServer),{:tweet,"how di do #fr",2})

    send(:global.whereis_name(:TwitterServer),{:user_register,1,self()})

    #subscribing 1 to 2 so 1 is a follower of 2
    send(:global.whereis_name(:TwitterServer),{:addSubscriber,1,2})

    send(:global.whereis_name(:TwitterServer),{:tweetsSubscribedTo,1})

    receive do
      {:repTweetsSubscribedTo,[tweet]} -> assert tweet=="how di do #fr"
    end


    
  end

  test "get hashtag query" do
    Task.async fn -> Twitter_Server.start_link() end
    :timer.sleep(3000)

    send(:global.whereis_name(:TwitterServer),{:user_register,2,self()})

    send(:global.whereis_name(:TwitterServer),{:tweet,"how di do #fr",2})

    send(:global.whereis_name(:TwitterServer),{:tweetsWithHashtag,"#fr",2})

    receive do
      {:repTweetsWithHashtag,[tweet]} -> assert tweet=="how di do #fr"
    end

  end

  test "mention query" do

    Task.async fn -> Twitter_Server.start_link() end
    :timer.sleep(3000)

    send(:global.whereis_name(:TwitterServer),{:user_register,2,:c.pid(0,250,0)})

    send(:global.whereis_name(:TwitterServer),{:user_register,1,self()})

    :timer.sleep(1000)

    send(:global.whereis_name(:TwitterServer),{:tweet,"how di do @1",2})

    :timer.sleep(1000)

    userId="1"
    [tup] = if :ets.lookup(:hashtags_mentions, "@" <> userId) != [] do
      :ets.lookup(:hashtags_mentions, "@" <> userId)
    else
      [{"#",[]}]
    end
    [tweet] = elem(tup, 1)

    assert tweet=="how di do @1"

    
    
  end

  test "login user" do
    Task.async fn -> Twitter_Server.start_link() end
    :timer.sleep(3000)
    
    send(:global.whereis_name(:TwitterServer),{:loginUser,1,self()})

    :timer.sleep(500)
    [{1,pid}] = :ets.lookup(:clientsregistry,1)

    assert pid==self()


  end

  test "logout user" do
    Task.async fn -> Twitter_Server.start_link() end
    :timer.sleep(3000)

    send(:global.whereis_name(:TwitterServer),{:user_register,2,self()})
    
    send(:global.whereis_name(:TwitterServer),{:disconnectUser,2})

    assert :ets.lookup(:clientsregistry,2)==[]


  end


  test "add subscriber" do
    Task.async fn -> Twitter_Server.start_link() end
    :timer.sleep(3000)

    send(:global.whereis_name(:TwitterServer),{:user_register,2,self()})

    send(:global.whereis_name(:TwitterServer),{:tweet,"how di do #fr",2})

    send(:global.whereis_name(:TwitterServer),{:user_register,1,self()})

    #subscribing 1 to 2 so 1 is a follower of 2
    send(:global.whereis_name(:TwitterServer),{:addSubscriber,1,2})

    :timer.sleep(1000)
    
    [tup] = :ets.lookup(:subscribedto, 1) 
    [sub_to] = elem(tup,1)  

    assert sub_to==2

  end



  
end
