defmodule MentionTweetIds do
    use GenServer
    #schema: mention string, tweetids [ints]

    defp get_keys(key, list) do
        if(key == :"$end_of_table") do
            list    
        else
            next = :ets.next(:mt_table, key)
            get_keys(next, [key | list])
        end    
    end

    def init(state) do
        :ets.new(:mt_table, [:set, :public, :named_table])
        {:ok, state}
    end

    #insert/update
    def handle_call({:insert_or_update, mentions, curr_tweet_id}, _from,state) do
        Enum.each(mentions, fn(mention) -> 
            if(:ets.lookup(:mt_table, mention) == []) do
                :ets.insert(:mt_table, {mention, [curr_tweet_id]})
            else
                list = :ets.lookup(:mt_table, mention) |> Enum.at(0) |> elem(1)
                :ets.delete(:mt_table, mention)
                :ets.insert(:mt_table, {mention, [curr_tweet_id | list]})
            end
        end)
        {:reply, :ok, state}
    end

    #get
    def handle_call({:get, :mention, mention}, _from, state) do
        list = if(mention == nil) do
            []
        else
            row = :ets.lookup(:mt_table, mention)
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
        first = :ets.first(:mt_table)
        list = get_keys(first, [])
        {:reply, list, state}
    end

    def handle_info(_msg, state) do #catch unexpected messages
        {:noreply, state}
    end 
    
end