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

    def connectToRandomNode(pid) do
      #IO.puts "calling random connect of process #{inspect pid}"
      GenServer.cast(pid,{:randomConnect})
    end

    def acknowledge(pid) do
      GenServer.cast(pid,:receiveOrder)
    end

    #SERVER API

    #routing table will be a keyword map with level values mapping to map of slot number to values with nil in slots where no entry and nodeid otherwise

    
    ######################################     INITIALIZING       ################################################
    def handle_cast({:initialize,n_id},_) do
      #IO.puts "initaliing with id #{n_id}"
      #levels are zero indexed
      max_routing_level = String.length(n_id) - 1
      row = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
      routing_row = Enum.map(row, fn x-> {x,nil} end) |> Enum.into(%{})
      my_routing_table = Enum.map(0..max_routing_level, fn x-> {x,routing_row} end) |> Enum.into(%{}) 
      {:noreply, {my_routing_table, n_id}} 
    end


    #######################################  ACKNOWLEDGED MUTLICAST ##########################################

    def handle_cast(:receiveOrder,{routing_table, node_id}) do
      #send a acknowledged multicast here
      {:ok, global_node_list} = Registry.meta(Registry.GlobalNodeList, :global)

      #drop your own nodeid from global_node_list
      global_node_list = Enum.filter(global_node_list, fn n -> n != node_id end)

      #for each nodeid, we get its pid from registry and send it a message that a node with this id has entered
      pids = Enum.map(global_node_list, fn n-> Matching.get_pid_from_registry(n) end)
      Enum.each(pids, fn p-> GenServer.cast(p,{:ackMulti,node_id}) end)
      {:noreply, {routing_table, node_id}}
    end
    
    
    def handle_cast({:ackMulti,n_id},{routing_table, node_id}) do
      
      #update the routing table

      match_length = Matching.max_prefix_match_length(node_id,n_id)
 
      route_row = Map.get(routing_table,match_length)


      #IO.puts "debugging n id is #{n_id} and match is #{match_length}"
      next_letter = String.at(n_id,match_length)


      slot_to_update = Map.get(route_row,next_letter)

      #cases slot is nil or not
      new_routing_table = case slot_to_update do
                              nil -> Matching.update_routing_table(node_id,routing_table,match_length,next_letter,n_id)
                              _   -> Matching.update_routing_table(node_id,routing_table,match_length,next_letter,Matching.decider(slot_to_update,n_id,node_id))
                          end


      {:noreply, {new_routing_table, node_id}}
    end


    ##################################          RANDOM CONNECT         #####################################################


    def handle_cast({:randomConnect}, {routing_table, node_id}) do
    
      {:ok, global_node_list} = Registry.meta(Registry.GlobalNodeList, :global)

      random_node_id = Enum.filter(global_node_list, fn n-> n != node_id end) |> Enum.random()

      #IO.puts "in random connect of node #{node_id} with pid #{inspect Matching.get_pid_from_registry(node_id)} with ultimate dest #{random_node_id}"
      #get pid of that random node
      pid = Matching.get_pid_from_registry(random_node_id)
      
      #consult with your routing table to find the closest entry, send message to it to random forward 
      closest_node_id = Matching.find_closest_entry_in_routing(node_id,random_node_id,routing_table)

      closest_pid = Matching.get_pid_from_registry(closest_node_id)

      #IO.puts "forwarding message from node #{node_id} to node #{closest_node_id} with closest pid #{inspect closest_pid}"

      GenServer.cast(closest_pid,{:randomForward,0,random_node_id})

      {:noreply,{routing_table, node_id}}
    end


    def handle_cast({:randomForward,hops_until_now,destination_node}, {routing_table, node_id}) do

      hops_taken = hops_until_now + 1
      #see if you are destination, else consult your routing table, find closest and random forward
      
      if !String.equivalent?(destination_node,node_id) do
        #consult with your routing table to find the closest entry, send message to it to random forward 
        closest_node_id = Matching.find_closest_entry_in_routing(node_id,destination_node,routing_table)
        #if !String.equivalent?(destination_node,closest_node_id) do
        closest_pid = Matching.get_pid_from_registry(closest_node_id)
        GenServer.cast(closest_pid,{:randomForward,hops_taken,destination_node})
      else
        {:ok,p} = Registry.meta(Registry.GlobalNodeList, :hopCounter)
        GenServer.cast(p,{:nodeFound,hops_taken})
      end
      
      
      {:noreply, {routing_table, node_id}}
    end

    ##########################################################################################################
    
    
end
  
    
  
  
  