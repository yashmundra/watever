defmodule MyApp do
  use Application

  def start(_type, _args) do
    
    numNodes = Enum.at(System.argv,0)
    topology = Enum.at(System.argv,1)
    algorithm = Enum.at(System.argv,2)

    #we geenrate a enum of {id,pid} of numnodes amount of actors
    #we need a formula that given topology and id, gives the neighboring nodes id for each topology


    {:ok,pid} = GenServer.start_link(MyActor, {:myid,:myTopology})
    IO.inspect GenServer.call(pid,"hello")
    IO.inspect GenServer.call(pid,"hello")
    #IO.puts max
    {:ok,pid}
  end
end

