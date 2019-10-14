defmodule RealNode do
    use GenServer
  
    def start_link(default) do
      GenServer.start_link(__MODULE__, default) 
    end
    
    def init(state) do
      {:ok,state}
    end
  

    #CLIENT API

    def publishObject(pid,msg) do
      GenServer.cast(pid,{:publishObj,msg})
    end

    def unpublishObject(pid,msg) do
      GenServer.cast(pid,{:unpublishObj,msg})
    end
    
    def routeToObject(pid,obj_id) do
      GenServer.cast(pid,{:routeToObj,obj_id})
    end

    def routeToNode(pid,node_id,exact) do
      GenServer.cast(pid,{:routeToNode,node_id,exact}) 
      end
    end

    def initialize(pid,node_id) do
      GenServer.cast(pid,{:initialize,node_id})
    end

    def setNeighbour(pid,list_of_neighbour_pids) do
      GenServer.cast(pid,{:setNbor,list_of_neighbour_pids})
    end

    #SERVER API
    #routing table will be a keyword map with level values mapping to enums with nil in slots where no entry and {nodeid,pid} otherwise
    #message to node map will store node as key and list of messages that node has

    def handle_cast({:publishObj,msg}, {node_to_message_map, routing_table, node_id}) do
      
      {:noreply, {node_to_message_map, routing_table, node_id}}
    end

    def handle_cast({:unpublishObj,msg},{node_to_message_map, routing_table, node_id}) do
      
      {:noreply, {node_to_message_map, routing_table, node_id}}
    end
    
    def handle_cast({:routeToObj,obj_id},{node_to_message_map, routing_table, node_id}) do
      
      {:noreply, {node_to_message_map, routing_table, node_id}}
    end

    def handle_cast({:routeToNode,node_id,exact},{node_to_message_map, routing_table, node_id}) do
      
      {:noreply, {node_to_message_map, routing_table, node_id}}
    end

    def handle_cast({:initialize,n_id},{node_to_message_map, routing_table, node_id}) do

      #64 routing levels and 16 slots . levels are zero indexed
      routing_row = Enum.map(1..16, fn x-> nil end)
      my_routing_table = Enum.each(0..63, fn x-> {x,routing_row} end) |> Enum.into(%{})

      {:noreply, {%{}, my_routing_table, n_id}}
    end
    
    def handle_cast({:setNbor,list_of_neighbour_pids},{node_to_message_map, routing_table, node_id}) do
      #update routing table
      #updates = Enum.each(list_of_neighbour_pids, fn pid -> {MyApp.hashStuff(pid),pid} end)
      #Enum.each(updates, fn {n,p} -> M)
      
      {:noreply, {node_to_message_map, routing_table, node_id}}
    end

end
  
    
  
  
  