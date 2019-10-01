 defmodule MyPushSumActor do
  
  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default) 
  end
  
  def init(state) do
    {:ok,state}
  end 
  
  #for initializing push sum actors
  def handle_cast({:initialize,s,w,pid_map,myid,positions,topology},_state) do
    #IO.puts "initialization message received"
    {:noreply,{s,w,nil,nil,pid_map,myid,positions,topology}}
  end

  #for push sum call
  def handle_cast({s,w}, {s1,w1,prev_estimate,prev_prev_estimate,pid_map,myid,positions,topology}) do
    threshold = :math.pow(10,-10)
    new_s = s + s1
    new_w = w + w1
    current_estimate = new_s/new_w
    #IO.puts "my id is #{myid} and my current estimate is #{current_estimate}"
    
    if (prev_prev_estimate != nil) and (abs(current_estimate-prev_prev_estimate) < threshold) do
      IO.puts "Stopping push sum actor"
      #IO.puts "current est - prev prev est and threshld"
      #IO.inspect current_estimate - prev_prev_estimate
      #IO.inspect threshold
      {:stop, :normal, {new_s,new_w,prev_estimate,prev_prev_estimate,pid_map,myid,positions,topology}}
    else
      prev_prev_estimate = prev_estimate
      prev_estimate = current_estimate
      neighbour_addrs = FindMyNeighbour.findmyneighbour(pid_map,myid,topology,positions)
      #IO.puts "neighbour addrs is "
      #IO.inspect neighbour_addrs
      
      #IO.inspect current_estimate
      send_msg_to_neighbours(neighbour_addrs,new_s/2,new_w/2)
      {:noreply,{new_s/2,new_w/2,prev_estimate,prev_prev_estimate,pid_map,myid,positions,topology}}
    end

  end

  def send_msg_to_neighbours(neighbour_addrs,a,b) do
    Enum.map(neighbour_addrs, fn addr -> GenServer.cast(addr,{a,b}) end )
  end

end