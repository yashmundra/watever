  defmodule Misc do
  
  def check_for_termination(pid_map,prev) do
    alive_map = Enum.map(pid_map, fn {k,v} -> Process.alive?(v) end) 
    #IO.puts("The process states are :")
    #IO.inspect(alive_map)
    count_of_all_processes = Enum.count(pid_map)
    count_of_dead_processes = Enum.filter(alive_map, fn x -> x==false end) |> Enum.count()

    
    if count_of_all_processes==count_of_dead_processes do
      next = System.monotonic_time(:millisecond)
      IO.puts("All actors have converged and time taken to converge is milliseconds")
      diff = next - prev
      IO.inspect diff
    else
      IO.puts("Trying again in 0.2 sec")
      Process.sleep(200)
      check_for_termination(pid_map,prev)
    end
  end

  def create_genservers(algorithm, numNodes) do
    
    if String.equivalent?(algorithm,"push-sum") do
      a = Enum.map(1..numNodes, fn x -> DynamicSupervisor.start_child(MyApp.DynamicSupervisor, MyPushSumActor) end) |> Enum.map(fn {:ok,x} -> x end)
      #a = Enum.map(1..numNodes, fn x -> GenServer.start_link(MyPushSumActor,[]) end) |> Enum.map(fn {:ok,x} -> x end)
      pid_map = Enum.zip(1..numNodes,a) |> Enum.into(%{})
    else
      a = Enum.map(1..numNodes, fn x -> DynamicSupervisor.start_child(MyApp.DynamicSupervisor, MyGossipActor) end) |> Enum.map(fn {:ok,x} -> x end)
      #a = Enum.map(1..numNodes, fn x -> GenServer.start_link(MyGossipActor,[]) end) |> Enum.map(fn {:ok,x} -> x end)
      pid_map = Enum.zip(1..numNodes,a) |> Enum.into(%{})
    end

  end

  end