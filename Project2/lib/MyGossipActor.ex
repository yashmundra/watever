defmodule MyGossipActor do
  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default) 
  end
  
  def init(state) do
    {:ok,state}
  end


  #for initializing gossip actors
  def handle_cast({:initialize,pid_map,myid,positions,topology},_state) do
    count = 0
    {:noreply,{count,pid_map,myid,positions, topology}}
  end

  def handle_cast({rumour}, {count,pid_map,myid,positions,topology}) do
    #select random neighbour and send rumour
    #IO.puts("received rumour")
    #GenServer.cast(findmyneighbour(pid_map,myid,topology,positions),{rumour})
    #GenServer.cast(process_id,{rumour})
    #IO.puts("sent rumour to a neighbour")

    #Needs to be modified so mesage is sent to all in case of full

    newcount = count+1
    #IO.puts "my id is #{myid} "

    if newcount >= 10 do
      IO.puts("I am stopping now")
      {:stop, :normal, {newcount, pid_map,myid,positions,topology}}
    else
      neighbour_addrs = FindMyNeighbour.findmyneighbour(pid_map,myid,topology,positions)
      #IO.puts "sending to following"
      #IO.inspect neighbour_addrs
      send_msg_to_neighbours(neighbour_addrs,{rumour})
      {:noreply, {newcount, pid_map,myid,positions,topology}}
    end
  end

  def send_msg_to_neighbours(neighbour_addrs,msg) do
    Enum.map(neighbour_addrs, fn addr -> GenServer.cast(addr,msg) end )
  end


end

  


