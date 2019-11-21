defmodule Server do
    use GenServer

   def start_link()do 
        GenServer.start_link(__MODULE__,[],name: Server)
   end

   def init(state) do
       # IO.puts "@!@!@!@!@!@!@!@!@!@!@!"

        :ets.new(:register, [:bag, :protected, :named_table])
        :ets.new(:followers, [:bag, :private, :named_table])
        :ets.new(:user_tweets, [:bag, :private, :named_table])
        #:ets.new(:tweet_h_m, [:bag, :private, :named_table])
        :ets.new(:hashtags, [:bag, :private, :named_table])
        :ets.new(:mentions, [:bag, :private, :named_table])
        :ets.new(:followee, [:bag, :private, :named_table])
       # :ets.new(:pending, [:bag, :private, :named_table])
    {:ok,state}
   end

   def handle_cast({:register,i},state) do

        clientName = "User#{i}"
        # IO.puts "IN SERVERRRRR REGISTER$$$$$"
        password= clientName<>"123"
       # IO.puts "client name is -----#{clientName}"
        h=:ets.insert(:register, {clientName,password,1})
       # IO.puts(h)
        list = :ets.lookup(:register, clientName)
        #IO.puts"########################################################## #{inspect list}"
     {:noreply,state}       
   end

   def handle_cast({:distTweet,tweet,user},state) do
    #  IO.puts "******************************#{user}    #{tweet}"

       # followerList=:ets.lookup(:followers,user)
        if (String.contains?tweet, "#") do
            hlist = ~r/#[^\s]+/ |> Regex.scan(tweet) |> Enum.map(&hd/1)
            # IO.puts("hlist-> #{inspect hlist}")
            Enum.each(hlist,fn x-> :ets.insert(:hashtags,{x,user,tweet}) end)
        
        end

        if(String.contains?tweet, "@") do
            alist = ~r/@[^\s]+/ |> Regex.scan(tweet) |> Enum.map(&hd/1)       
            #  IO.puts "alist#{inspect alist}"
             Enum.each(alist,fn x-> :ets.insert(:mentions,{x,user,tweet})end)
             Enum.each(alist, fn y-> :ets.insert(:user_tweets,{String.slice(y,1..-1),user,tweet})end)
        end     
        
        #Just Tweet
      #  IO.puts"After hlist alist%$%$%$%$%$%$%$%$"
        :ets.insert(:user_tweets, {user,tweet})
       # IO.puts"%$%$%$%$%$%$%$%$"

    {:noreply,state}
   end

   def handle_cast({:showTweet,user},state) do
    #IO.puts "handlecast showtweet**********************************"
     list=:ets.lookup(:user_tweets,user)
   
     followee_list=:ets.lookup(:followee,user)
     size=Enum.count(followee_list)
     sublist=[]
     sublist= for i<- 0..size-1 do
        {_,followee}=Enum.at(followee_list,i)
        #IO.inspect followee
        sublist=[:ets.lookup(:user_tweets,followee)|sublist]
        sublist
     end
     sender=String.to_atom(user)
     GenServer.cast(sender,{:display,user,list,sublist})
    # list=:ets.lookup(:user_tweets,"User2")
    #  IO.puts "#{inspect list}"
    {:noreply,state}
   end 

   def handle_cast({:queryTweet,user,query},state) do

        hashtag_list=:ets.lookup(:hashtags,query)
        sender=String.to_atom(user)
        GenServer.cast(sender,{:displayquery,user,hashtag_list})

    {:noreply,state}
   end

   def handle_cast({:retweet_server,user,numClients},state) do

        tweetlist= :ets.lookup(:user_tweets,user)    
        size=Enum.count(tweetlist)
        IO.puts "#{size} #{inspect tweetlist}"
        if(size<0) do
            index=Enum.random(0..size-1)
            {_,_,tweet}=Enum.at(tweetlist,index)
            retweet="RETWEET:"<>tweet
            :ets.insert(:user_tweets,{user,retweet})
        end
             
    {:noreply,state}
   end

   def handle_cast({:setFollowers,users,follower},state) do
        # IO.puts "User is #{users}, Followers are #{follower}"
        :ets.insert(:followers,{users,follower})
        list = :ets.lookup(:followers,users)
       # IO.puts "#{inspect list}"
    {:noreply,state}
   end

   def handle_cast({:add_followee_list,user1, user2},state) do

        :ets.insert(:followee, {user1, user2})
    {:noreply,state}
   end

end