defmodule MyApp do
  use Application

  def start(_type, _args) do
    
    {numNodes, ""} = Integer.parse(Enum.at(System.argv,0))
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
    
    
    IO.puts("Calculating positions")
    positions = nil
    if String.equivalent?(topology,"rand2D") do
      positions = Enum.map(pid_map,fn {k,v} -> {k,{:rand.uniform(2)-1,:rand.uniform(2)-1}} end) |> Enum.into(%{})
    end

    #Initializing Genservers
    if String.equivalent?(algorithm,"gossip") do #for gossip
      IO.puts("Initializing Genservers")
      Enum.each(pid_map,fn {k,v} -> GenServer.cast(v,{:initialize,pid_map,k,positions,topology}) end)
      IO.puts("Starting distributed communication")
      {:ok,process_id} = Map.fetch(pid_map,1)
      GenServer.cast(process_id,{rumour})
    else #push sum
      IO.puts("Initializing Genservers")
      Enum.each(pid_map,fn {k,v} -> GenServer.cast(v,{:initialize,k,w,pid_map,k,positions,topology}) end)
      IO.puts("Starting distributed communication")
      {:ok,process_id} = Map.fetch(pid_map,1)
      GenServer.cast(process_id,{1,1})
    end


    IO.puts("Checking for termination")
    checker(pid_map)

  end

  def checker(pid_map) do
    count = Enum.map(pid_map, fn {k,v} -> Process.info(v) end) |> Enum.count(fn x -> x == nil end)

    if count == Enum.count(pid_map) do
      IO.puts("Terminated")
    else
      Process.sleep(2000)
      checker(pid_map)
    end
  end

end

