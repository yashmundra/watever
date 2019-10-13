defmodule Node do
  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default) 
  end
  
  def init(state) do
    {:ok,state}
  end


  #for initializing gossip actors
  #def handle_cast({:initialize,pid_map,myid,positions,topology},_state) do
  #  count = 0
  #  {:noreply,{count,pid_map,myid,positions, topology}}
  #end

  def handle_cast({rumour}, {count,pid_map,myid,positions,topology}) do

    newcount = count+1
    #IO.puts newcount
    #IO.puts "my id is #{myid} "
    #neighbour_addrs = FindMyNeighbour.findmyneighbour(pid_map,myid,topology,positions)
    if newcount >= 10 do
      #IO.puts("I am stopping now")
      {:stop, :normal, {newcount, pid_map,myid,positions,topology}}
    else
      neighbour_addrs = FindMyNeighbour.findmyneighbour(pid_map,myid,topology,positions)
      
      #IO.puts "before nebor state is "
      #IO.inspect neighbour_addrs
      #if neighbour_addr are all dead then kill yourself
      neighbour_addrs = Enum.filter(neighbour_addrs, fn addr -> Process.alive?(addr) end)

      #if all neighbours are dead then die too
      #IO.puts "after nebor state is "
      #IO.inspect neighbour_addrs

      if Enum.empty?(neighbour_addrs) do
          #IO.puts "Its all false"
          {:stop, :normal, {newcount, pid_map,myid,positions,topology}}
      else
          #IO.puts "Sending msg to people"
          send_msg_to_neighbours(neighbour_addrs,{rumour})
          {:noreply, {newcount, pid_map,myid,positions,topology}}
      end
    end
  end

  # def send_msg_to_neighbours(neighbour_addrs,msg) do
  #   Enum.map(neighbour_addrs, fn addr -> GenServer.cast(addr,msg) end )
  # end


end

  


