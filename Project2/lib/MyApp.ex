defmodule MyApp do
  use Application

  def start(_type, _args) do
    
    numNodes = Enum.at(System.argv,0)
    topology = Enum.at(System.argv,1)
    algorithm = Enum.at(System.argv,2)
    rumour = "Hi"
    w = 1
    
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
    
    if String.equivalent?(topology,"rand2D") do
      positions = Enum.map(pid_map,fn {k,v} -> {k,{:rand.uniform(2)-1,:rand.uniform(2)-1}}) |> Enum.into(%{})
    else
      positions = nil
    end

    #Initializing Genservers
    if String.equivalent?(algorithm,"gossip") do
      Enum.each(pid_map,fn {k,v} -> GenServer.call(v,{:initialize,rumour,pid_map,k,positions,topology}))
    else #push sum
      Enum.each(pid_map,fn {k,v} -> GenServer.call(v,{:initialize,k,w,pid_map,k,positions,topology}))
    end






    #{:ok,pid} = GenServer.start_link(MyActor, {:myid,:myTopology})
    IO.inspect GenServer.call(pid,"hello")
    IO.inspect GenServer.call(pid,"hello")
    #IO.puts max
    {:ok,pid}
  end
end

