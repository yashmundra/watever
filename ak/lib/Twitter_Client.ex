defmodule Twitter_Client do
    use GenServer

    def start_link(userId,tweetCount,msgs,flag_bool) do
        GenServer.start_link(__MODULE__, [userId,tweetCount,msgs,flag_bool])
    end

    def make_distributed([head | tail],l) do
        unless Node.alive?() do
            try do
                {ip_tuple,_,_} = head
                current_ip = to_string(:inet_parse.ntoa(ip_tuple))
                if current_ip === "127.0.0.1" do
                    if l > 1 do
                        make_distributed(tail,l-1)
                    end
                else
                    server_node_name = String.to_atom("client@" <> current_ip)
                    Node.start(server_node_name)
                    Node.set_cookie(server_node_name,:monster)
                    Node.connect(String.to_atom("server@" <> current_ip))
                end
            rescue
                _ -> if l > 1, do: make_distributed(tail,l-1)
            end
        end
    end

    def init([userId,noOfTweets,noToSubscribe,existingUser]) do
        {:ok,iflist}=:inet.getif()
        make_distributed(Enum.reverse(iflist),length(iflist))
        :global.sync()

        if existingUser do
            func_login(userId)
        end
        
        #Register Account
        send(:global.whereis_name(:TwitterServer),{:user_register,userId,self()})
        server_interact(userId,noOfTweets,noToSubscribe)
        receive do: (_ -> :ok)
    end

    def func_login(userId) do
        send(:global.whereis_name(:TwitterServer),{:loginUser,userId,self()})
        for _ <- 1..5 do
            send(:global.whereis_name(:TwitterServer),{:tweet,"this dude #{userId} says that jimmy #{random_string_generate(5)} had always be gone",userId})
        end
        querying_for_tweets(userId)
    end

    def server_interact(userId,noOfTweets,noToSubscribe) do

        #Subscribe
        if noToSubscribe > 0 do
            subList = generate_subList(1,noToSubscribe,[])
            send_sub_req(userId,subList)
        end

        start_time = System.system_time(:millisecond)
        #Mention
        userToMention = :rand.uniform(String.to_integer(userId))
        send(:global.whereis_name(:TwitterServer),{:tweet,"#{userId} tweeting a mention to @#{userToMention}",userId})

        #Hashtag
        send(:global.whereis_name(:TwitterServer),{:tweet,"#{userId} making use of hashtags #whatever",userId})

        #Send Tweets
        for _ <- 1..noOfTweets do
            send(:global.whereis_name(:TwitterServer),{:tweet,"#{userId} says #{random_string_generate(5)} could be cuter",userId})
        end

        #ReTweet
        sending_retweeting(userId)
        tweets_time_diff = System.system_time(:millisecond) - start_time

        #Queries
        start_time = System.system_time(:millisecond)
        querying_tweets_from_subscription(userId)
        queries_subscribedto_time_diff = System.system_time(:millisecond) - start_time
        
        start_time = System.system_time(:millisecond)
        querying_for_specific_hashtag("#whatever",userId)
        queries_hashtag_time_diff = System.system_time(:millisecond) - start_time

        start_time = System.system_time(:millisecond)
        querying_mentioning_tweet(userId)
        queries_mention_time_diff = System.system_time(:millisecond) - start_time

        start_time = System.system_time(:millisecond)
        #Get All Tweets
        fetch_tweets_send_rq(userId)
        queries_myTweets_time_diff = System.system_time(:millisecond) - start_time

        tweets_time_diff = tweets_time_diff/(noOfTweets+3)
        send(:global.whereis_name(:mainproc),{:perfmetrics,tweets_time_diff,queries_subscribedto_time_diff,queries_hashtag_time_diff,queries_mention_time_diff,queries_myTweets_time_diff})

        #Live View
        querying_for_tweets(userId)
    end

    def generate_subList(count,noOfSubs,list) do
        if(count == noOfSubs) do 
            [count | list]
        else
            generate_subList(count+1,noOfSubs,[count | list]) 
        end
    end

    

    def sending_retweeting(userId) do
        send(:global.whereis_name(:TwitterServer),{:tweetsSubscribedTo,userId})
        list = receive do
            {:repTweetsSubscribedTo,list} -> list
        end
        if list != [] do
            rt = hd(list)
            send(:global.whereis_name(:TwitterServer),{:tweet,rt <> " -retweet",userId})
        end
    end

    def fetch_tweets_send_rq(userId) do
        send(:global.whereis_name(:TwitterServer),{:getMyTweets,userId})
        receive do
            {:repGetMyTweets,list} -> IO.puts "#{userId} says all #{list}"
        end
    end

    def send_sub_req(userId,subscribeToList) do
        Enum.each subscribeToList, fn accountId -> 
            send(:global.whereis_name(:TwitterServer),{:addSubscriber,userId,Integer.to_string(accountId)})
        end
    end

    def querying_for_tweets(userId) do
        receive do
            {:live,tweetString} -> IO.puts "#{userId} is saying #{tweetString}"
        end
        querying_for_tweets(userId)
    end

    def querying_for_specific_hashtag(tag,userId) do
        send(:global.whereis_name(:TwitterServer),{:tweetsWithHashtag,tag,userId})
        receive do
            {:repTweetsWithHashtag,list} -> IO.puts "#{userId} says #{list}"
        end
    end

    def random_string_generate(l) do
        :crypto.strong_rand_bytes(l) |> Base.url_encode64 |> binary_part(0, l) |> String.upcase
      end

    def querying_tweets_from_subscription(userId) do
        send(:global.whereis_name(:TwitterServer),{:tweetsSubscribedTo,userId})
        receive do
            {:repTweetsSubscribedTo,list} ->  if list != [], do: IO.puts "#{userId} subscribes to following #{list}"
        end
    end

    

    def querying_mentioning_tweet(userId) do
         send(:global.whereis_name(:TwitterServer),{:tweetsWithMention,userId})
        receive do
            {:repTweetsWithMention,list} -> IO.puts "#{userId} says mention #{list}"
        end
    end

    

end