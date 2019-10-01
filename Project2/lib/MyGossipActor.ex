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

    newcount = count+1
    #IO.puts "my id is #{myid} "
    #neighbour_addrs = FindMyNeighbour.findmyneighbour(pid_map,myid,topology,positions)
    if newcount >= 10 do
      IO.puts("I am stopping now")
      {:stop, :normal, {newcount, pid_map,myid,positions,topology}}
    else
      neighbour_addrs = FindMyNeighbour.findmyneighbour(pid_map,myid,topology,positions)
      #IO.puts "sending to following"
      #IO.inspect neighbour_addrs
      #if neighbour_Addr are all dead then kill yourself
      nebor_state = Enum.map(neighbour_addrs, fn addr -> Process.alive?(addr) end)

      #if all neighbours are dead then die too
      IO.puts "nebor state is "
      IO.inspect nebor_state
      
      if Enum.all?(nebor_state, fn x -> x==false end) do
          {:stop, :normal, {newcount, pid_map,myid,positions,topology}}
      else
          send_msg_to_neighbours(neighbour_addrs,{rumour})
          {:noreply, {newcount, pid_map,myid,positions,topology}}
      end
    end
  end

  def send_msg_to_neighbours(neighbour_addrs,msg) do
    Enum.map(neighbour_addrs, fn addr -> GenServer.cast(addr,msg) end )
  end


end

  


