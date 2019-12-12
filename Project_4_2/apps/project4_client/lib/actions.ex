defmodule Actions do

    defp loop do
        :timer.sleep(1000000000)
        loop()
    end

    defp print_tweet_rate(total_tweets, epoch) do
        total_tweets = receive do
          {:print, num_tweets} ->
            next = System.monotonic_time(:microsecond)
            total_time = next - epoch
            total_tweets = total_tweets + num_tweets
            rate = (total_tweets / (total_time)) * 1000000
            IO.inspect "total_tweets: #{total_tweets}"
            IO.inspect "running average: #{rate} tweets per second"
            total_tweets
        end
        IO.inspect "Waiting for next batch.."
        print_tweet_rate(total_tweets, epoch)
    end

    def make_em_tweet(num_users, client_pids, tweets, see) do
        0..num_users-1 |> Enum.each(fn(idx) -> GenServer.cast(Enum.at(client_pids, idx), {:tweet, tweets, idx, see}) end )
    end

    def subscribe_to(userId, subscribeToId, engine_pid) do
        GenServer.call(engine_pid, {:subscribe, userId, subscribeToId})   
    end

    def get_sample_hashtags(engine_pid) do
        GenServer.call(engine_pid, {:hashtag, :getkeys})
    end

    def get_tweets_with_hashtag(hashtag, engine_pid) do
        GenServer.call(engine_pid, {:hashtag, :hashtag, hashtag})
    end

    def get_sample_mentions(engine_pid) do
        GenServer.call(engine_pid, {:mention, :getkeys})
    end

    def get_tweets_with_mention(mention, engine_pid) do
        GenServer.call(engine_pid, {:mention, :mention, mention})
    end

    def get_feed(userid, engine_pid) do
        GenServer.call(engine_pid, {:feed, userid})
    end

    def simulate(engine_pid, num_users, see) do
        zipf_factor = 100/1000 #(factor / fraction of a millisecond wait time) 
        print_every_factor = 3
        hashtags_size = 1000
        mentions_size = 1000
        tweets_size = 8000
    
        #register client-master
        client_master_pid = self()
        :ok = GenServer.call(engine_pid, {:register_client_master, client_master_pid, num_users * print_every_factor})
        
        #prepare hashtags, mentions, tweets
        hashtags = Utils.get_hashtags(0, hashtags_size, [])
        mentions = Utils.get_mentions(hashtags_size, hashtags_size + mentions_size, [])
        tweets = Utils.get_tweets(hashtags_size + mentions_size,hashtags_size + mentions_size + tweets_size, hashtags, hashtags_size,mentions, mentions_size,[], true, false, 0, 0)
    
        #start users
        state = %{:hashtags => hashtags,
        :mentions => mentions,
        :num_users => num_users, 
        :zipf_factor => zipf_factor, 
        :engine_pid => engine_pid}

        IO.inspect "Spawning all users"
    
        client_pids = 0..num_users-1 |> Enum.map(fn(rank) -> GenServer.start_link(Client, Map.put(state, :rank, rank) ) |> elem(1)  end)
    
        IO.inspect "Registering all users"

        #register all users
        Enum.each(client_pids, fn(pid) -> GenServer.call(pid, :register) end )
    
        IO.inspect "Registered all users\n "

        #make clients subscribe by zipf (power law)

        # IO.inspect "Subscribing by zipf law"
        # Enum.each(client_pids, fn(pid) -> GenServer.call(pid, :subscribe) end )
        # IO.inspect "Created zipf distribution of subscription model"
        
        #make clients tweet by zipf law (80-20)
        Task.start(Actions, :make_em_tweet, [num_users, client_pids, tweets, see])

        IO.inspect "Users have started tweeting"
    
        if(see == :see_tweet_rate) do
            IO.inspect "Waiting for first tweet-rate-results to arrive.."
            print_tweet_rate(0, System.monotonic_time(:microsecond))
        else
            #loop infinitely
            loop()
        end

    end

    def retweet(userid, engine_pid) do
        retweet = get_feed(userid, engine_pid) |> Enum.take_random(1) |> Enum.at(0)
        IO.inspect "retweeting: " <> retweet
        GenServer.call(engine_pid, {:tweet, userid, retweet})
    end
end