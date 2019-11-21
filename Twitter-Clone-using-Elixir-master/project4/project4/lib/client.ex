defmodule Client do
        use GenServer
    

    def start_link(i)do
        # IO.puts "Here in client start_link"
        # IO.puts "Name of client is #{String.to_atom(clientName)}"
        GenServer.start_link(__MODULE__,i,name: :"User#{i}")
    end

    def init(i) do
    #IO.puts"IN INIT IF CLIENT///////555555555555555555555555555555555"
    GenServer.cast(Server,{:register,i})
    {:ok,i}
    end

    def handle_cast({:send_Tweet,time,user,numClient},state) do

        #  IO.puts "{}{}{}{}{}{}{}{}{}{}{{}{}{}{{}handlecast sendtweet #{user}**********************************"
        tweet= createTweet(numClient)
       #tweet="Hey you!#Boo@User2"
        GenServer.cast(Server,{:distTweet,tweet,user})
        :timer.sleep(time);
        GenServer.cast(self(),{:send_Tweet,time,user,numClient})

      {:noreply,state}
    end

    def handle_cast({:show_Tweet,user},state) do

        GenServer.cast(Server,{:showTweet,user})
        :timer.sleep(30)
        GenServer.cast(self(),{:show_Tweet,user})
     {:noreply,state}
    end
    
    def handle_cast({:query_tweet, user,numClient},state) do

        hashtags=["#husky","#boo","#elixi","#final","#pizza","#UF","#GoGators","#Nirvana","#GunnRoses","#Happy"]
        sizeh=Enum.count(hashtags)
        index=:rand.uniform(sizeh)-1
        query=Enum.at(hashtags,index)
        GenServer.cast(Server,{:queryTweet,user,query})     
        :timer.sleep(30)
        GenServer.cast(self(),{:query_tweet,user,numClient})   

     {:noreply,state}
    end

    def handle_cast({:displayquery,user,hashtag_list},state) do

     :timer.sleep(1000) 
     IO.puts " "
     IO.puts " "
     IO.puts "~~~~~~~~~~~~~~~~~~#{user} Query Notification~~~~~~~~~~~~~~~~~~~"
     IO.puts " "
     IO.puts "Results with the hashtag: #{inspect hashtag_list}"
     IO.puts " "

        {:noreply,state}
    end

    def handle_cast({:display,user,list,sublist},state) do

     :timer.sleep(1000)   
     IO.puts " "
     IO.puts " "
     IO.puts "~~~~~~~~~~~~~~~~~~#{user} Notification~~~~~~~~~~~~~~~~~~~"
     IO.puts " "
     IO.puts "Personal Tweets: #{inspect list}"
     IO.puts " "
     IO.puts "Received Tweets: #{inspect sublist}"
        {:noreply,state}
    end

    def handle_cast({:retweet_client,user,numClients},state) do

        GenServer.cast(Server,{:retweet_server,user,numClients})
        :timer.sleep(2000)
        GenServer.cast(self(),{:retweet_client,user,numClients})
     {:noreply,state}
    end

    
    def createTweet(numClient) do
        tweets=["booyaaaaaaaaa.", "Merry christmas", "Where do you wanno go?" ,"Scooby Dooby doo.","Imma so hungry.","How you doing?","Welcome to the jungle.","Take me home to the paradise city."]
        hashtags=["#husky","#boo","#elixi","#final","#pizza","#UF","#GoGators","#Nirvana","#GunnRoses","#Happy"]
        sizet=Enum.count(tweets)
        sizeh=Enum.count(hashtags)
         index1=:rand.uniform(sizet)-1
         index2=:rand.uniform(sizeh)-1
        #   IO.puts"#{index1}..#{index2}.."
        mentions="@User"<>Integer.to_string(:rand.uniform(numClient))
        tweet=Enum.at(tweets,index1)<>" "<>Enum.at(hashtags,index2)<>" "<>mentions
        # IO.puts "#{tweet}"
        tweet
    end

end