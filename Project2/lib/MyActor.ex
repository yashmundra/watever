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
    {:noreply, state+1}
  end

  #for push sum
  def handle_call({s,w},_from, {s1,w1,last_estimate,second_last_estimate}) do
    news = s+s1
    neww = w+ w1
    #select random and send news/2,neww/2
    {:noreply,{div(news,2),div(neww,2)}}
  end
end
