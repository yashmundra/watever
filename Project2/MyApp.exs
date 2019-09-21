defmodule MyApp do
  use Application

  def start(_type, _args) do
    
    numNodes = Integer.parse(Enum.at(System.argv,0))
    topology = Enum.at(System.argv,1)
    algorithm = Enum.at(System.argv,2)
    rumour = "Hi"
    w = 1
    
    children = [
  		{DynamicSupervisor, strategy: :one_for_one, name: MyApp.DynamicSupervisor}
	]

    Supervisor.start_link(children, strategy: :one_for_one)
 
    #{id,pid} pid map generated
    IO.puts("Creating Genservers")
    a = Enum.map(1..numNodes, fn x -> DynamicSupervisor.start_child(MyApp.DynamicSupervisor, MyActor) end) |> Enum.map(fn {:ok,x} -> x end)
    pid_map = Enum.zip(1..numNodes,a) |> Enum.into(%{})
    
    #initilaize the actors with the topology, pidmap and their id
    #pick one and send thema  rumor
    #wait and collect terminations from every actor
    #return success
    
    IO.puts("Calculating positions")
    if String.equivalent?(topology,"rand2D") do
      positions = Enum.map(pid_map,fn {k,v} -> {k,{:rand.uniform(2)-1,:rand.uniform(2)-1}}) |> Enum.into(%{})
    else
      positions = nil
    end


    IO.puts("Initializing Genservers")
    #Initializing Genservers
    if String.equivalent?(algorithm,"gossip") do
      Enum.each(pid_map,fn {k,v} -> GenServer.call(v,{:initialize,pid_map,k,positions,topology}))
      GenServer.call(Map.fetch(pid_map,1),{rumour})
    else #push sum
      Enum.each(pid_map,fn {k,v} -> GenServer.call(v,{:initialize,k,w,pid_map,k,positions,topology}))
      GenServer.call(Map.fetch(pid_map,1),{1,1})
    end


    IO.puts("Checking for termination")
    checker(pid_map)

  end

  def checker(pid_map) do
    count = Enum.map(pid_map, fn {k,v} -> Process.info(v)) |> Enum.count(fn x -> x == nil end)
    if count == Enum.count(pid_map) do
      :success
    else
      Process.sleep(2000)
      checker(pid_map)
    end
  end

end

