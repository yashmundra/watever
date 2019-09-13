defmodule MyGenServer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, []) 
  end
  
  def run(pid,{min,max}) do
    GenServer.call(pid,{min,max})
  end

  def init(_) do
    #Added Task supervisor to monitor all workers
    Supervisor.start_link([{Task.Supervisor, name: MySupervisor}], strategy: :one_for_one)
  end

  def handle_call({min,max}, _, state) do
    #constructing worker unit ranges
    workerUnits = 30
    sz = Enum.take_every(min..max, workerUnits) |> Enum.map(fn x -> {x,x+workerUnits-1} end)
    new = Enum.take(sz, Enum.count(sz)-1)
    {_,b} = Enum.at(new,Enum.count(new)-1)
    myranges = Enum.concat(new,[{b+1,max}])

    #actual concurrent execution of Vampire Search
    stream = Task.Supervisor.async_stream(MySupervisor,myranges,Vampire, :mainfunc, [], max_concurrency: 10)
    answer = Enum.to_list(stream) |> Enum.filter(fn {:ok,x} -> x != [] end) |> Enum.map(fn {:ok,x} -> x end) |> Enum.map(fn x -> Enum.reduce(x,"",fn x,acc -> acc<>x<>"\n" end) end)
    {:reply,answer,state}
  end

end
