defmodule HashtagTweetIds do
    use GenServer
    #schema: hashtag string, tweetids [ints]

    defp get_keys(key, list) do
        if(key == :"$end_of_table") do
            list    
        else
            next = :ets.next(:ht_table, key)
            get_keys(next, [key | list])
        end    
    end

    def init(state) do
        :ets.new(:ht_table, [:set, :public, :named_table])
        {:ok, state}
    end

    #insert/update
    def handle_call({:insert_or_update, hashtags, curr_tweet_id}, _from, state) do
        Enum.each(hashtags, fn(hashtag) -> 
            if(:ets.lookup(:ht_table, hashtag) == []) do
                :ets.insert(:ht_table, {hashtag, [curr_tweet_id]})
            else
                list = :ets.lookup(:ht_table, hashtag) |> Enum.at(0) |> elem(1)
                :ets.delete(:ht_table, hashtag)
                :ets.insert(:ht_table, {hashtag, [curr_tweet_id | list]})
            end
        end)
        {:reply, :ok, state}
    end

    #get hashtag
    def handle_call({:get, :hashtag, hashtag}, _from, state) do
        list = if (hashtag == nil) do
            []
        else
            row = :ets.lookup(:ht_table, hashtag)
            if row == [] do
                []
            else
                row |> Enum.at(0) |> elem(1)     
            end
        end
        
        {:reply, list, state}
    end

    #get keys
    def handle_call({:get, :keys}, _from, state) do
        first = :ets.first(:ht_table)
        list = get_keys(first, [])
        {:reply, list, state}
    end

    def handle_info(_msg, state) do #catch unexpected messages
        {:noreply, state}
    end 
    
end