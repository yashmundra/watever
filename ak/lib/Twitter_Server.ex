defmodule Twitter_Server do
    use GenServer

    def start_link() do
        GenServer.start_link(__MODULE__, :ok)
    end

    def whereis(userId) do
        if :ets.lookup(:clientsregistry, userId) == [] do
            nil
        else
            [tup] = :ets.lookup(:clientsregistry, userId)
            elem(tup, 1)
        end
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
                    server_node_name = String.to_atom("server@" <> current_ip)
                    Node.start(server_node_name)
                    Node.set_cookie(server_node_name,:monster)
                end
            rescue
                _ -> if l > 1, do: make_distributed(tail,l-1)
            end
        end
    end

    def init(:ok) do
        {:ok,iflist}=:inet.getif()
        make_distributed(Enum.reverse(iflist),length(iflist))
        :ets.new(:clientsregistry, [:set, :public, :named_table])
        :ets.new(:tweets, [:set, :public, :named_table])
        :ets.new(:hashtags_mentions, [:set, :public, :named_table])
        :ets.new(:subscribedto, [:set, :public, :named_table])
        :ets.new(:followers, [:set, :public, :named_table])
        server_id = spawn_link(fn() -> api_handler() end) 
        :global.register_name(:TwitterServer,server_id)
        receive do: (_ -> :ok) 
    end

    def api_handler() do
        receive do
            {:user_register,userId,pid} -> register_user(userId,pid)
                                          send(pid,{:registerConfirmation})
            {:tweet,tweetString,userId} -> process_tweet(tweetString,userId)
            {:tweetsSubscribedTo,userId} -> Task.start fn -> tweets_subscribed_to(userId) end
            {:tweetsWithHashtag,hashTag,userId} -> Task.start fn -> tweets_with_hashtag(hashTag,userId) end
            {:tweetsWithMention,userId} -> Task.start fn -> tweets_with_mention(userId) end
            {:getMyTweets,userId} -> Task.start fn -> get_my_tweets(userId) end
            {:addSubscriber,userId,subId} -> add_subscribed_to(userId,subId)
                                             add_followers(subId,userId)
            {:disconnectUser,userId} -> disconnect_user(userId)
            {:loginUser,userId,pid} -> :ets.insert(:clientsregistry, {userId, pid})
        end
        api_handler()
    end

    def register_user(userId,pid) do
        :ets.insert(:clientsregistry, {userId, pid})
        :ets.insert(:tweets, {userId, []})
        :ets.insert(:subscribedto, {userId, []})
        if :ets.lookup(:followers, userId) == [], do: :ets.insert(:followers, {userId, []})
    end

    def disconnect_user(userId) do
        :ets.insert(:clientsregistry, {userId, nil})
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
        send(whereis(userId),{:repGetMyTweets,list})
    end

    def get_subscribed_to(userId) do
        [tup] = :ets.lookup(:subscribedto, userId)
        elem(tup, 1)
    end

    def get_followers(userId) do
        [tup] = :ets.lookup(:followers, userId)
        elem(tup, 1)
    end

    def add_subscribed_to(userId,sub) do
        [tup] = :ets.lookup(:subscribedto, userId)
        list = elem(tup, 1)
        list = [sub | list]
        :ets.insert(:subscribedto, {userId, list})
    end

    def add_followers(userId,foll) do
        if :ets.lookup(:followers, userId) == [], do: :ets.insert(:followers, {userId, []})
        [tup] = :ets.lookup(:followers, userId)
        list = elem(tup, 1)
        list = [foll | list]
        :ets.insert(:followers, {userId, list})
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

        [{_,followersList}] = :ets.lookup(:followers, userId)
        Enum.each followersList, fn follower -> 
	        if whereis(follower) != nil, do: send(whereis(follower),{:live,tweetString})
        end
    end

    def insert_tags(tag,tweetString) do
        [tup] = if :ets.lookup(:hashtags_mentions, tag) != [] do
            :ets.lookup(:hashtags_mentions, tag)
        else
            [nil]
        end
        if tup == nil do 
            :ets.insert(:hashtags_mentions,{tag,[tweetString]})
        else
            list = elem(tup,1)
            list = [tweetString | list]
            :ets.insert(:hashtags_mentions,{tag,list})
        end
    end

    def tweets_subscribed_to(userId) do 
        subscribedTo = get_subscribed_to(userId)
        list = generate_tweet_list(subscribedTo,[])
        send(whereis(userId),{:repTweetsSubscribedTo,list})
    end

    def generate_tweet_list([head | tail],tweetlist) do
        tweetlist = get_tweets(head) ++ tweetlist
        generate_tweet_list(tail,tweetlist)
    end

    def generate_tweet_list([],tweetlist), do: tweetlist

    def tweets_with_hashtag(hashTag, userId) do 
        [tup] = if :ets.lookup(:hashtags_mentions, hashTag) != [] do
            :ets.lookup(:hashtags_mentions, hashTag)
        else
            [{"#",[]}]
        end
        list = elem(tup, 1)
        send(whereis(userId),{:repTweetsWithHashtag,list})
    end

    def tweets_with_mention(userId) do
        [tup] = if :ets.lookup(:hashtags_mentions, "@" <> userId) != [] do
            :ets.lookup(:hashtags_mentions, "@" <> userId)
        else
            [{"#",[]}]
        end
        list = elem(tup, 1)
        send(whereis(userId),{:repTweetsWithMention,list})
    end
end