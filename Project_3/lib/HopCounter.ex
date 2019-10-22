defmodule HopCounter do
    use GenServer
  
    def start_link(default) do
      GenServer.start_link(__MODULE__, default) 
    end
    
    def init(state) do
      {:ok,state}
    end

    def handle_cast({:nodeFound,hops},{successCount,max_hops}) do
        IO.puts "comparing between #{hops} and #{max_hops}"
        {:noreply,{successCount+1,max(hops,max_hops)}}
    end 

    def handle_cast({:initialize},_) do
        {:noreply,{0,0}}
    end

    def handle_call({:answer},_,{successCount,max_hops}) do
        {:reply,{successCount,max_hops},max_hops}
    end




end