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

    #routing table will be a keyword map with level values mapping to map of slot number to values with nil in slots where no entry and nodeid otherwise
    
    ######################################   INITIALIZING ###################################################
    def handle_cast({:initialize,n_id},{routing_table, node_id}) do
      #levels are zero indexed
      max_routing_level = String.length(n_id) - 1
      routing_row = Enum.map(1..16, fn x-> {x,nil} end) |> Enum.into(%{})
      my_routing_table = Enum.each(0..max_routing_level, fn x-> {x,routing_row} end) |> Enum.into(%{})

      #send a acknowledged multicast here
      {:ok, global_node_list} = Registry.meta(Registry.GlobalNodeList, :global)

      #drop your own nodeid from global_node_list
      global_node_list = Enum.filter(global_node_list, fn n-> n!=n_id end)

      #for each nodeid, we get its pid from registry and send it a message that a node with this id has entered
      pids = Enum.each(global_node_list, fn n-> Matching.get_pid_from_registry(n) end)
      Enum.each(pids, fn p-> GenServer.cast(p,{:ackMulti,n_id}) end)
      {:noreply, {my_routing_table, n_id}}
    end


    #######################################  ACKNOWLEDGED MUTLICAST ##########################################

    def handle_cast({:ackMulti,n_id},{routing_table, node_id}) do
      
      #update the routing table
      new_routing_table = routing_table

      #find out how many prefix match for n_id and node_id, go to that number level , 
      #find next digit and put in that slot, if already there , see which one is closer to node_id
      #put that one there.
      match_length = Matching.max_prefix_match_length(node_id,n_id)

      route_row = Map.get(routing_table,match_length)

      #slot to update

      {:noreply, {new_routing_table, n_id}}
    end


    
    
end
  
    
  
  
  