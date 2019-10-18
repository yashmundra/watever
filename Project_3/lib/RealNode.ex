defmodule RealNode do
    use GenServer
  
    def start_link(default) do
      GenServer.start_link(__MODULE__, default) 
    end
    
    def init(state) do
      {:ok,state}
    end
  

    #CLIENT API

    def initialize(pid,node_id) do
      GenServer.cast(pid,{:initialize,node_id})
    end

    #SERVER API

    #routing table will be a keyword map with level values mapping to enums with nil in slots where no entry and nodeid otherwise
    
    def handle_cast({:initialize,n_id},{routing_table, node_id}) do
      #levels are zero indexed
      max_routing_level = String.length(n_id) - 1
      routing_row = Enum.map(1..16, fn x-> nil end)
      my_routing_table = Enum.each(0..max_routing_level, fn x-> {x,routing_row} end) |> Enum.into(%{})

      #send a acknowledged multicast here
      {:ok, global_node_list} = Registry.meta(Registry.GlobalNodeList, :global)

      #drop your own nodeid from global_node_list
      global_node_list = Enum.filter(global_node_list, fn n-> n!=n_id end)

      #for each nodeid, we get its pid from registry and send it a message that a node with this id has entered
      {:noreply, {my_routing_table, n_id}}
    end
    
    
end
  
    
  
  
  