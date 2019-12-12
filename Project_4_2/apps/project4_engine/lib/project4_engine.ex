defmodule TwitterEngine do
  @moduledoc """
  Documentation for TwitterEngine.
  """
  
  def loop() do
    :timer.sleep(1000000000)
    loop()
  end

  def main(args) do

    #starter process
    self() |> Process.register(:master)

    #5 tables
    elem(GenServer.start_link(UserIdSubscribedtoSubscribers, []), 1) |> Process.register(:uss)
    elem(GenServer.start_link(UserIdTweetIds, []), 1) |> Process.register(:ut)
    elem(GenServer.start_link(HashtagTweetIds, []), 1) |> Process.register(:ht)
    elem(GenServer.start_link(MentionTweetIds, []), 1) |> Process.register(:mt)
    elem(GenServer.start_link(TweetIdTweet, []), 1) |> Process.register(:tt)
    elem(GenServer.start_link(UserIdChannelPId, []), 1) |> Process.register(:uc)

    #engine
    #epmd -daemon
    state = %{:curr_user_id => 0, :curr_tweet_id => 0}
    :global.register_name(:engine, GenServer.start_link(Engine, state) |> elem(1)) 

    IO.inspect "Twitter engine started"

    #loop infinitely
    loop()

  end
end
