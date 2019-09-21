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

  #handles three different types of calls
  #one to initilize itself
  #one to receive and handle push sum
  #one to handle gossip 
  #maintains internal state which is either a rumor count / or a s,w pair
  def handle_call(rumour, _, state) do
    IO.inspect state
    state = Tuple.append(state,"hi")
    {:reply,rumour,state}
  end
end
