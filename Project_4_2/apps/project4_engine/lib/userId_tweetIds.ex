defmodule UserIdTweetIds do
    use GenServer
    #schema: userid int, tweetids [ints]

    def init(state) do
        :ets.new(:ut_table, [:set, :public, :named_table])
        {:ok, state}
    end

    #insert/update
    def handle_call({:insert_or_update, userId, curr_tweet_id}, _from,state) do
        if(:ets.lookup(:ut_table, userId) == []) do
            :ets.insert(:ut_table, {userId, [curr_tweet_id]})
        else
            list = :ets.lookup(:ut_table, userId) |> Enum.at(0) |> elem(1)
            :ets.delete(:ut_table, userId)
            :ets.insert(:ut_table, {userId, [curr_tweet_id | list]})
        end
        {:reply, :ok, state}
    end

    #get
    def handle_call({:get, userId}, _from, state) do
        list = :ets.lookup(:ut_table, userId) |> Enum.at(0) |> elem(1)     
        {:reply, list, state}
    end

    def handle_info(_msg, state) do #catch unexpected messages
        {:noreply, state}
    end 
    
end