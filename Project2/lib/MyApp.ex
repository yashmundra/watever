defmodule MyApp do
  use Application

  def start(_type, _args) do
    
    numNodes = Enum.at(System.argv,0)
    topology = Enum.at(System.argv,1)
    algorithm = Enum.at(System.argv,2)

    {:ok,pid} = GenServer.start_link(MyActor, {:myid,:myTopology})
    IO.inspect GenServer.call(pid,"hello")
    IO.inspect GenServer.call(pid,"hello")
    #IO.puts max
    {:ok,pid}
  end
end

