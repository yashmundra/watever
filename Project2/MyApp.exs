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

    ret_value = Supervisor.start_link(children, strategy: :one_for_one)


    #first make sure numNodes is correct for honeycomb and torus / divisible by 6 and a cube
    if String.equivalent?(topology,"honeycomb") or String.equivalent?(topology,"randhoneycomb") do
      remainder = rem(numNodes,6)
      if rem(numNodes+remainder,6)==0 do
        numNodes = numNodes+remainder
      else
        numNodes = numNodes-remainder
      end

    end
    
    if String.equivalent?(topology,"3Dtorus") do
      #Need to make numNodes is a cube
      IO.puts "still remaining"
    end

    IO.puts("Creating Genservers")
    pid_map = create_genservers(algorithm,numNodes)    

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


    IO.puts("Checking for termination and showing process states")
    #show_process_states(pid_map)

    IO.puts "the end"

    ret_value

  end


  def show_process_states(pid_map) do
    alive_map = Enum.map(pid_map, fn {k,v} -> {k,Process.alive?(v)} end) 
    IO.puts("The process states are :")
    IO.inspect(alive_map)
    show_process_states(pid_map)
  end

  def create_genservers(algorithm, numNodes) do
    
    if String.equivalent?(algorithm,"push-sum") do
      a = Enum.map(1..numNodes, fn x -> DynamicSupervisor.start_child(MyApp.DynamicSupervisor, MyPushSumActor) end) |> Enum.map(fn {:ok,x} -> x end)
      pid_map = Enum.zip(1..numNodes,a) |> Enum.into(%{})
    else
      a = Enum.map(1..numNodes, fn x -> DynamicSupervisor.start_child(MyApp.DynamicSupervisor, MyGossipActor) end) |> Enum.map(fn {:ok,x} -> x end)
      pid_map = Enum.zip(1..numNodes,a) |> Enum.into(%{})
    end

  end

end

