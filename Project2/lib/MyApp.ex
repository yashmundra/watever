defmodule MyApp do
  use Application

  def start(_type, _args) do
    
    numNodes = Enum.at(System.argv,0)
    topology = Enum.at(System.argv,1)
    algorithm = Enum.at(System.argv,2)
    
    children = [
  		{DynamicSupervisor, strategy: :one_for_one, name: MyApp.DynamicSupervisor}
	]

    Supervisor.start_link(children, strategy: :one_for_one)
 
    #{id,pid} pid map generated
    a = Enum.map(1..numNodes, fn x -> DynamicSupervisor.start_child(MyApp.DynamicSupervisor, MyActor) end) |> Enum.map(fn {:ok,x} -> x end)
    pid_map = Enum.zip(1..numNodes,a) |> Enum.into(%{})
    
    #initilaize the actors with the topology, pidmap and their id
    #pick one and send thema  rumor
    #wait and collect terminations from every actor
    #return success



    #{:ok,pid} = GenServer.start_link(MyActor, {:myid,:myTopology})
    IO.inspect GenServer.call(pid,"hello")
    IO.inspect GenServer.call(pid,"hello")
    #IO.puts max
    {:ok,pid}
  end
end

