defmodule Twitter_Server do
    use GenServer

    def start_link() do
        GenServer.start_link(__MODULE__, :ok)
    end

    def whereis(userId) do
        if :ets.lookup(:id_pid_map, userId) == [] do
            nil
        else
            [tup] = :ets.lookup(:id_pid_map, userId)
            elem(tup, 1)
        end
    end

    def init(:ok) do
        {:ok,iflist}=:inet.getif()
        run_dist(Enum.reverse(iflist),length(iflist))
        :ets.new(:id_pid_map, [:set, :public, :named_table])
        :ets.new(:tag_twt_map, [:set, :public, :named_table])
        :ets.new(:tweets, [:set, :public, :named_table])
        :ets.new(:id_to_subid_map, [:set, :public, :named_table])
        :ets.new(:id_to_follow_map, [:set, :public, :named_table])
        server_id = spawn_link(fn() -> call_mapper() end) 
        :global.register_name(:TwitterServer,server_id)
        receive do: (_ -> :ok) 
    end

    def register_user(userId,pid) do
        :ets.insert(:id_pid_map, {userId, pid})
        :ets.insert(:tweets, {userId, []})
        :ets.insert(:id_to_subid_map, {userId, []})
        if :ets.lookup(:id_to_follow_map, userId) == [], do: :ets.insert(:id_to_follow_map, {userId, []})
    end

    def disconnect_user(userId) do
        :ets.insert(:id_pid_map, {userId, nil})
    end

    def get_tweets(userId) do
        if :ets.lookup(:tweets, userId) == [] do
            []
        else
            [tup] = :ets.lookup(:tweets, userId)
            elem(tup, 1)
        end
    end

    def get_my_tweets(userId) do
        [tup] = :ets.lookup(:tweets, userId)
        list = elem(tup, 1)
        send(whereis(userId),{:tweet_res,list})
    end

    def get_subscribed_to(userId) do
        [tup] = :ets.lookup(:id_to_subid_map, userId)
        elem(tup, 1)
    end

    def get_followers(userId) do
        [tup] = :ets.lookup(:id_to_follow_map, userId)
        elem(tup, 1)
    end

    def add_subscribed_to(userId,sub) do
        [tup] = :ets.lookup(:id_to_subid_map, userId)
        list = elem(tup, 1)
        list = [sub | list]
        :ets.insert(:id_to_subid_map, {userId, list})
    end

    def add_followers(userId,foll) do
        if :ets.lookup(:id_to_follow_map, userId) == [], do: :ets.insert(:id_to_follow_map, {userId, []})
        [tup] = :ets.lookup(:id_to_follow_map, userId)
        list = elem(tup, 1)
        list = [foll | list]
        :ets.insert(:id_to_follow_map, {userId, list})
    end

    def run_dist([head | tail],l) do
        unless Node.alive?() do
            try do
                {ip_tuple,_,_} = head
                my_ip = to_string(:inet_parse.ntoa(ip_tuple))
                if my_ip === "127.0.0.1" do
                    if l > 1 do
                        run_dist(tail,l-1)
                    end
                else
                    srv_name = String.to_atom("server@" <> my_ip)
                    Node.start(srv_name)
                    Node.set_cookie(srv_name,:monster)
                end
            rescue
                _ -> if l > 1, do: run_dist(tail,l-1)
            end
        end
    end
    
   
    def process_tweet(tweetString,userId) do
        [tup] = :ets.lookup(:tweets, userId)
        list = elem(tup,1)
        list = [tweetString | list]
        :ets.insert(:tweets,{userId,list})
        
        hashtagsList = Regex.scan(~r/\B#[a-zA-Z0-9_]+/, tweetString) |> Enum.concat
        Enum.each hashtagsList, fn hashtag -> 
	        insert_tags(hashtag,tweetString)
        end
        mentionsList = Regex.scan(~r/\B@[a-zA-Z0-9_]+/, tweetString) |> Enum.concat
        Enum.each mentionsList, fn mention -> 
	        insert_tags(mention,tweetString)
            userName = String.slice(mention,1, String.length(mention)-1)
            if whereis(userName) != nil, do: send(whereis(userName),{:live,tweetString})
        end

        [{_,followersList}] = :ets.lookup(:id_to_follow_map, userId)
        Enum.each followersList, fn follower -> 
	        if whereis(follower) != nil, do: send(whereis(follower),{:live,tweetString})
        end
    end

    def insert_tags(tag,tweetString) do
        [tup] = if :ets.lookup(:tag_twt_map, tag) != [] do
            :ets.lookup(:tag_twt_map, tag)
        else
            [nil]
        end
        if tup == nil do 
            :ets.insert(:tag_twt_map,{tag,[tweetString]})
        else
            list = elem(tup,1)
            list = [tweetString | list]
            :ets.insert(:tag_twt_map,{tag,list})
        end
    end

    def call_mapper() do
        receive do
            {:user_register,userId,pid} -> register_user(userId,pid)
                                          send(pid,{:registerConfirmation})
            {:tweet,tweetString,userId} -> process_tweet(tweetString,userId)
            {:find_follow_tweet,userId} -> Task.start fn -> tweets_subscribed_to(userId) end
            {:qry_hashtg_tweet,hashTag,userId} -> Task.start fn -> tweets_with_hashtag(hashTag,userId) end
            {:qry_mention,userId} -> Task.start fn -> tweets_with_mention(userId) end
            {:getFeeds,userId} -> Task.start fn -> get_my_tweets(userId) end
            {:sub_add_follow,userId,subId} -> add_subscribed_to(userId,subId)
                                             add_followers(subId,userId)
            {:disconnectUser,userId} -> disconnect_user(userId)
            {:loginUser,userId,pid} -> :ets.insert(:id_pid_map, {userId, pid})
        end
        call_mapper()
    end

    def tweets_subscribed_to(userId) do 
        subscribedTo = get_subscribed_to(userId)
        list = generate_tweet_list(subscribedTo,[])
        send(whereis(userId),{:sub_res,list})
    end

    def generate_tweet_list([head | tail],tweetlist) do
        tweetlist = get_tweets(head) ++ tweetlist
        generate_tweet_list(tail,tweetlist)
    end

    def generate_tweet_list([],tweetlist), do: tweetlist

    def tweets_with_hashtag(hashTag, userId) do 
        [tup] = if :ets.lookup(:tag_twt_map, hashTag) != [] do
            :ets.lookup(:tag_twt_map, hashTag)
        else
            [{"#",[]}]
        end
        list = elem(tup, 1)
        send(whereis(userId),{:tag_res,list})
    end

    def tweets_with_mention(userId) do
        [tup] = if :ets.lookup(:tag_twt_map, "@" <> userId) != [] do
            :ets.lookup(:tag_twt_map, "@" <> userId)
        else
            [{"#",[]}]
        end
        list = elem(tup, 1)
        send(whereis(userId),{:mention_res,list})
    end
end