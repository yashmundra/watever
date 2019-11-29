defmodule Twitter_Client do
    use GenServer

    def start_link(userId,tweetCount,msgs,flag_bool) do
        GenServer.start_link(__MODULE__, [userId,tweetCount,msgs,flag_bool])
    end



    def init([userId,tweetCount,msgs,existingUser]) do
        {:ok,iflist}=:inet.getif()
        run_dist(Enum.reverse(iflist),length(iflist))
        :global.sync()

        if existingUser do
            func_login(userId)
        end
        
        #Register Account
        send(:global.whereis_name(:TwitterServer),{:user_register,userId,self()})
        server_interact(userId,tweetCount,msgs)
        receive do: (_ -> :ok)
    end

    def func_login(userId) do
        send(:global.whereis_name(:TwitterServer),{:loginUser,userId,self()})
        for _ <- 1..5 do
            send(:global.whereis_name(:TwitterServer),{:tweet,"this dude #{userId} says that jimmy #{random_string_generate(5)} had always be gone",userId})
        end
        querying_for_tweets(userId)
    end

    def server_interact(userId,tweetCount,msgs) do

        #Subscribe
        if msgs > 0 do
            subList = generate_subList(1,msgs,[])
            send_sub_req(userId,subList)
        end

        start_time = System.system_time(:millisecond)
        #Mention
        userToMention = :rand.uniform(String.to_integer(userId))
        send(:global.whereis_name(:TwitterServer),{:tweet,"#{userId} tweeting a mention to @#{userToMention}",userId})

        #Hashtag
        send(:global.whereis_name(:TwitterServer),{:tweet,"#{userId} making use of hashtags #whatever",userId})

        #Send Tweets
        for _ <- 1..tweetCount do
            send(:global.whereis_name(:TwitterServer),{:tweet,"#{userId} says #{random_string_generate(5)} could be cuter",userId})
        end

        #ReTweet
        sending_retweeting(userId)
        metric_1 = System.system_time(:millisecond) - start_time

        #Queries
        start_time = System.system_time(:millisecond)
        querying_tweets_from_subscription(userId)
        metric_2 = System.system_time(:millisecond) - start_time
        
        start_time = System.system_time(:millisecond)
        querying_for_specific_hashtag("#whatever",userId)
        metric_3 = System.system_time(:millisecond) - start_time

        start_time = System.system_time(:millisecond)
        querying_mentioning_tweet(userId)
        metric_4 = System.system_time(:millisecond) - start_time

        start_time = System.system_time(:millisecond)
        #Get All Tweets
        fetch_tweets_send_rq(userId)
        metric_5 = System.system_time(:millisecond) - start_time

        metric_1 = metric_1/(tweetCount+3)
        send(:global.whereis_name(:proc_stat),{:simul_met,metric_1,metric_2,metric_3,metric_4,metric_5})

        #Live View
        querying_for_tweets(userId)
    end

    def run_dist(x,l) do
        [head|tail] = x
        unless Node.alive?() do
            try do
                {ip_tuple,_,_} = head
                my_ip = to_string(:inet_parse.ntoa(ip_tuple))
                if my_ip === "127.0.0.1" do
                    if l > 1 do
                        run_dist(tail,l-1)
                    end
                else
                    srv_name = String.to_atom("client@" <> my_ip)
                    Node.start(srv_name)
                    Node.set_cookie(srv_name,:monster)
                    Node.connect(String.to_atom("server@" <> my_ip))
                end
            rescue
                _ -> if l > 1, do: run_dist(tail,l-1)
            end
        end
    end

    def generate_subList(count,noOfSubs,list) do
        if(count == noOfSubs) do 
            [count | list]
        else
            generate_subList(count+1,noOfSubs,[count | list]) 
        end
    end

    

    def sending_retweeting(userId) do
        send(:global.whereis_name(:TwitterServer),{:find_follow_tweet,userId})
        list = receive do
            {:sub_res,list} -> list
        end
        if list != [] do
            rt = hd(list)
            send(:global.whereis_name(:TwitterServer),{:tweet,rt <> " -retweet",userId})
        end
    end

    def fetch_tweets_send_rq(userId) do
        send(:global.whereis_name(:TwitterServer),{:getFeeds,userId})
        receive do
            {:tweet_res,list} -> IO.puts "#{userId} says all #{list}"
        end
    end

    def send_sub_req(userId,subscribeToList) do
        Enum.each subscribeToList, fn accountId -> 
            send(:global.whereis_name(:TwitterServer),{:sub_add_follow,userId,Integer.to_string(accountId)})
        end
    end

    def querying_for_tweets(userId) do
        receive do
            {:live,tweetString} -> IO.puts "#{userId} is saying #{tweetString}"
        end
        querying_for_tweets(userId)
    end

    def querying_for_specific_hashtag(tag,userId) do
        send(:global.whereis_name(:TwitterServer),{:qry_hashtg_tweet,tag,userId})
        receive do
            {:tag_res,list} -> IO.puts "#{userId} says #{list}"
        end
    end

    def random_string_generate(l) do
        :crypto.strong_rand_bytes(l) |> Base.url_encode64 |> binary_part(0, l) |> String.upcase
      end

    def querying_tweets_from_subscription(userId) do
        send(:global.whereis_name(:TwitterServer),{:find_follow_tweet,userId})
        receive do
            {:sub_res,list} ->  if list != [], do: IO.puts "#{userId} subscribes to following #{list}"
        end
    end

    

    def querying_mentioning_tweet(userId) do
         send(:global.whereis_name(:TwitterServer),{:qry_mention,userId})
        receive do
            {:mention_res,list} -> IO.puts "#{userId} says mention #{list}"
        end
    end

    

end