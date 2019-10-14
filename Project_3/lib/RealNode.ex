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
    #routing table will be a keyword map with level values mapping to enums with nil in slots where no entry

    def handle_cast({:publishObj,msg}, {list_of_local_messages, routing_table, node_id}) do
      
      {:noreply, {list_of_local_messages, routing_table, node_id}}
    end

    def handle_cast({:unpublishObj,msg},{list_of_local_messages, routing_table, node_id}) do
      
      {:noreply, {list_of_local_messages, routing_table, node_id}}
    end
    
    def handle_cast({:routeToObj,obj_id},{list_of_local_messages, routing_table, node_id}) do
      
      {:noreply, {list_of_local_messages, routing_table, node_id}}
    end

    def handle_cast({:routeToNode,node_id,exact},{list_of_local_messages, routing_table, node_id}) do
      
      {:noreply, {list_of_local_messages, routing_table, node_id}}
    end

    def handle_cast({:initialize,n_id},{list_of_local_messages, routing_table, node_id}) do
      {:noreply, {[], %{}, n_id}}
    end
    
    def handle_cast({:setNbor,list_of_neighbour_pids},{list_of_local_messages, routing_table, node_id}) do
      #update routing table
      
      {:noreply, {list_of_local_messages, routing_table, node_id}}
    end

end
  
    
  
  
  