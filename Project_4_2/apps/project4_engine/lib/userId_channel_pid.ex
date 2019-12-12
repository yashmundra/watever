defmodule UserIdChannelPId do
    use GenServer
    #schema userid, channelpid

    def init(state) do
        :ets.new(:uc_table, [:set, :public, :named_table])
        {:ok, state}
    end

    #insert
    def handle_call({:insert, userid, channelpid}, _from,state) do
        :ets.insert(:uc_table, {userid, channelpid})
        IO.inspect "Inserted"
        IO.inspect userid
        IO.inspect "Channelpid: "
        IO.inspect channelpid
        {:reply, :ok, state}
    end

    #get
    def handle_call({:get, userid}, _from, state) do
        {_, channelpid} = :ets.lookup(:uc_table, userid) |> Enum.at(0)  
        {:reply, channelpid, state}
    end

    #catch unexpected messages
    def handle_info(_msg, state) do 
        {:noreply, state}
    end 
    
end