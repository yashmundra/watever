defmodule Project4 do
      use GenServer
  
  def main(argv) do
   # start_link()
                 
     GenServer.start_link(__MODULE__,[],name: Simulator)     
    arg=List.wrap(argv);
    numClients= String.to_integer(List.first(arg))

    dist=zipf(numClients)
    #IO.puts("zipf distribution: #{inspect(dist)}")
    Server.start_link()
   
    for i <- 1..numClients do
             clientName = "User#{i}"           
             clientPID =Client.start_link(i)          
    end

    v = 0.9*numClients |> round
    v = Enum.random(v..numClients)
    total_followers = v/dist[1] |> round
     # IO.puts("Total number of followers: #{total_followers}")
     createFollowers(dist, numClients, total_followers)
    # GenServer.cast(Simulator,{:tweet, 2})
    # GenServer.cast(self(),{:sendTweet,dist,numClients})
    sendTweet(dist,numClients)
    # spawn(fn->sendTweet(dist,numClients)end)
    #:timer.sleep(2000)
    spawn(fn->showTweet(numClients) end)
     #:timer.sleep(1500)
    spawn(fn->queryTweet(numClients)end)
     :timer.sleep(6000)
    retweet(numClients)
    # showTweet(numClients)
    # queryTweet(numClients)
    receive do
      
    end
     
  end


  def zipf(n, alpha \\ 1) do
        c = 1/Enum.reduce(1..n, 0, fn (x, acc) -> 
            acc = acc + 1/:math.pow(x,alpha) end)
        Enum.reduce(1..n, %{}, fn (x, acc) -> 
            acc = Map.put(acc, x, c/:math.pow(x,alpha)) end)
  end

  def createFollowers(dist, numClients, total_followers) do
        clients = Enum.map(1..numClients,fn x -> "User#{x}" end)
       followers= for i <- 1..numClients do
            users = List.delete_at(clients, i-1)
            followers = Enum.take_random(users, dist[i]*total_followers|>round)
            #IO.puts ("User #{i} followers: #{inspect(followers)}")
            #IO.puts "BEFORE SET FOLOEWESSSSS"
            GenServer.cast(Server, {:setFollowers, "User#{i}", followers})
            followers
        end

         followers |> Enum.with_index |> Enum.each(fn({x, i}) -> 
            Enum.map(x, fn(y) -> 
                GenServer.cast(Server, {:add_followee_list, y, "User#{i+1}"})
            end)
         end)

  end



  def sendTweet(dist,numClients) do  


    
    for i <- 1..numClients do
        time=(1/(dist[i]*numClients)*1000) |>round
        GenServer.cast(:"User#{i}", {:send_Tweet,time,"User#{i}",numClients})
    end
  end    
    
  def showTweet(numClients) do

  # IO.puts "################# showtweet simulator"
      for i<- 1..numClients do
        GenServer.cast(:"User#{i}", {:show_Tweet,"User#{i}"})
      end 
  # IO.puts "showtweet**********************************"
  # list=:ets.lookup(:user_tweets,user)
    #  list=:ets.lookup(:user_tweets,"User2")    
  end

  def queryTweet(numClients) do

       i=:rand.uniform(numClients-1)
       GenServer.cast(:"User#{i}", {:query_tweet,"User#{i}",numClients})
      

  end

  def retweet(numClients) do

    for i<- 1..numClients do
       GenServer.cast(:"User#{i}", {:retweet_client,"User#{i}",numClients})
    end
  end

  def init([]) do
    state=0;
    {:ok,state}
  end

end