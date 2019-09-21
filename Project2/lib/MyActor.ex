defmodule MyActor do
  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default) 
  end
  
  def init(state) do
    #Added Task supervisor to monitor all workers
    #Supervisor.start_link([{Task.Supervisor, name: MySupervisor}], strategy: :one_for_one)
    #state is {topology,id}
    {:ok,state}
  end

  def gossip(pid,rumour) do
    GenServer.call(pid,{rumour})
  end
  

  #handles three different types of calls
  #one to initilize itself
  #one to receive and handle push sum
  #one to handle gossip 
  #maintains internal state which is either a rumor count / or a s,w pair
  def handle_call({rumour}, _from, state) do
    #select random and send rumour
    newstate = state+1
    #if newstate > 10
    #{:stop, :normal, state}
    #else
    #{:noreply, newstate}
  end

  #for push sum
  def handle_call({s,w},_from, {s1,w1,prev_estimate,prev_prev_estimate}) do
    new_s = s + s1
    new_w = w + w1
    current_estimate = div(new_s,new_w)
    #if current_estimate-prev_prev_estimate < threshold
    #termination code {:stop, :normal, state}
    #else
    #prev_prev_estimate = prev_estimate
    #prev_estimate = current_estimate
    #select random and send new_s/2,new_w/2
    #{:noreply,{div(new_s,2),div(new_w,2),prev_estimate,prev_prev_estimate}}
  end

  def handle_call(request,_from, []) do

  end

  
end
