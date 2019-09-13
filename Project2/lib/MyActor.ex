defmodule MyActor do
  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default) 
  end
  
  def init(state) do
    #Added Task supervisor to monitor all workers
    Supervisor.start_link([{Task.Supervisor, name: MySupervisor}], strategy: :one_for_one)
    #state is {id,topology}
    {:ok,state}
  end

  def handle_call(rumour, _, state) do
    IO.inspect state
    state = Tuple.append(state,"hi")
    {:reply,rumour,state}
  end
end
