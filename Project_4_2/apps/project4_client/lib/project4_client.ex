defmodule TwitterClient do
  @moduledoc """
  Documentation for TwitterClient.
  """

# arguments
# ./project4_client simulate see_tweets NUM_CLIENTS (tweet)
# ./project4_client simulate see_tweet_rate NUM_CLIENTS (tweet)
# ./project4_client subscribe_to USERID_1 USERID_2
# ./project4_client sample_hashtags
# ./project4_client tweets_with_hashtag HASHTAG  #(HASHTAG should be WITHOUT the '#' symbol)
# ./project4_client sample_mentions
# ./project4_client tweets_with_mention MENTION
# ./project4_client feed USERID
# ./project4_client retweet USERID

  def main(args) do

    # connect to engine
    # epmd -daemon
    {:ok, _} = Node.start(String.to_atom("client@127.0.0.1")) 
    Application.get_env(:p4, :cookie) |> Node.set_cookie 
    _ = Node.connect(String.to_atom("engine@127.0.0.1")) #connect to master
    :global.sync #sync global registry to let slave know of master being named :master
    engine_pid = :global.whereis_name(:engine)

    action = Enum.at(args, 0)
    result = case action do
      "simulate" -> 
        see = Enum.at(args, 1)
        see = case see do
          "see_tweets" -> :see_tweets
          "see_tweet_rate" -> :see_tweet_rate
          _ -> raise "Incorrect parameter"
        end
        num_users = Enum.at(args, 2) |> String.to_integer
       Actions.simulate(engine_pid, num_users, see)
      "subscribe_to" -> 
        userid = Enum.at(args, 1) |> String.to_integer
        subscribeToId = Enum.at(args, 2) |> String.to_integer
        Actions.subscribe_to(userid, subscribeToId, engine_pid)
      "sample_hashtags" -> Actions.get_sample_hashtags(engine_pid)
      "tweets_with_hashtag" -> 
        hashtag = Enum.at(args, 1)
        Actions.get_tweets_with_hashtag("#" <> hashtag, engine_pid)
      "sample_mentions" ->Actions.get_sample_mentions(engine_pid)
      "tweets_with_mention" ->
        mention = Enum.at(args, 1)
        Actions.get_tweets_with_mention(mention, engine_pid)
      "feed" -> 
        userid = Enum.at(args, 1) |> String.to_integer
        Actions.get_feed(userid, engine_pid)
      "retweet" -> 
        userid = Enum.at(args, 1) |> String.to_integer
        Actions.retweet(userid, engine_pid)
      _ -> raise "Incorrect parameter"       
    end

    IO.inspect result

  end
end
