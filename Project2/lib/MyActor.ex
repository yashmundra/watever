defmodule MyActor do
  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default) 
  end
  
  def init(state) do
    {:ok,state}
  end

  #for initializing gossip actors
  def handle_call({:initialize,rumour,pid_map,myid,positions,topology},_from, _state) do
    count = 1
    {:noreply,{count,pid_map,myid,positions, topology}}
  end

  #gossip call
  def handle_call({rumour}, _from, {count,pid_map,myid,positions,topology}) do
    #select random neighbour and send rumour
    GenServer.call(findmyneighbour(pid_map,myid,topology,positions),{rumour})
    newcount = count+1
    cond do
      newcount > 10 -> {:stop, :normal, newcount, pid_map,myid,positions,topology}
      newcount <= 10 -> {:noreply, newcount, pid_map,myid,positions,topology}
    end
  end



###################################################        PUSH SUM   ########################################################################
  #for initializing push sum actors
  def handle_call({:initialize,s,w,pid_map,myid,positions,topology},_from, _state) do
    {:noreply,{s,w,nil,nil,pid_map,myid,positions,topology}}
  end

  #for push sum call
  def handle_call({s,w},_from, {s1,w1,prev_estimate,prev_prev_estimate,pid_map,myid,positions,topology}) do
    threshold = :math.pow(10,-10)
    new_s = s + s1
    new_w = w + w1
    current_estimate = div(new_s,new_w)
    
    if current_estimate-prev_prev_estimate < threshold do
      {:stop, :normal, {new_s,new_W,prev_estimate,prev_prev_estimate,pid_map,myid,positions,topology}}
    else
      prev_prev_estimate = prev_estimate
      prev_estimate = current_estimate
      GenServer.call(findmyneighbour(pid_map,myid,topology,positions),{div(new_s,2),div(new_w,2)})
      {:noreply,{div(new_s,2),div(new_w,2),prev_estimate,prev_prev_estimate,pid_map,myid,positions,topology}}
    end

  end

 
#####################################################     NEIGHBOUR SEARCH   ###################################################################

  def findmyneighbour(pid_map,myid,topology,positions) do
    
    case topology do
    'full' -> neighbours = FindMyNeighbour.full(pid_map,myid)
    'line' -> neighbours = FindMyNeighbour.line(pid_map,myid)
    'rand2D' -> neighbours = FindMyNeighbour.rand2D(positions,pid_map,myid)
    '3Dtorus' -> neighbours = FindMyNeighbour.torus(pid_map,myid)
    'honeycomb' -> neighbours = FindMyNeighbour.honeycomb(pid_map,myid)
    'randhoneycomb' -> neighbours = FindMyNeighbour.randhoneycomb(pid_map,myid)
    end

    Enum.random(neighbours)

  end

end
