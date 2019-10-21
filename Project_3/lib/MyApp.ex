defmodule MyApp do
  use Application

  def start(_type, _args) do
    
    numNodes = elem(Integer.parse(Enum.at(System.argv,0)),0)
    numRequests = elem(Integer.parse(Enum.at(System.argv,1)),0)

    children = [{DynamicSupervisor, strategy: :one_for_one, name: MyApp.DynamicSupervisor}]

    ret_value = Supervisor.start_link(children, strategy: :one_for_one)

    pids = Enum.map(1..numNodes, fn x -> DynamicSupervisor.start_child(MyApp.DynamicSupervisor, RealNode) end) |> Enum.map(fn {:ok,x} -> x end)
    
    pid_to_nodeid_map = Enum.map(pids, fn pid -> {pid,hashStuff(:rand.uniform())} end) |> Enum.into(%{})

    
    node_ids = Map.values(pid_to_nodeid_map)

    IO.puts "node ids are #{inspect node_ids}"

    #starting counter 
    {:ok,counter_pid} = DynamicSupervisor.start_child(MyApp.DynamicSupervisor, HopCounter) 
    GenServer.cast(counter_pid,{:initialize})

    #initialize elixir registry 
    #registry will consist of :global key with all node ids enum as value
    #and nodeid keys with their pids as value
    Registry.start_link(keys: :unique, name: Registry.GlobalNodeList)
    Registry.put_meta(Registry.GlobalNodeList, :global, node_ids)
    Registry.put_meta(Registry.GlobalNodeList,:hopCounter, counter_pid)
    Enum.map(pid_to_nodeid_map, fn {p,n} -> Registry.put_meta(Registry.GlobalNodeList, {:tuple,n}, p) end)

    #initializing nodes with their unique id's
    Enum.each(pids, fn pid -> RealNode.initialize(pid,Map.get(pid_to_nodeid_map,pid)) end)

    #Process.sleep(10000)
    IO.puts "initializing"
    print_loading_message(5)

    Enum.each(pids, fn pid -> RealNode.acknowledge(pid) end)

    IO.puts "multicasting"
    print_loading_message(5)

    #asking the nodes to connect to randomNodes for numRequests times
    IO.puts "random conencting"
    Enum.map(1..numRequests, fn x-> callRandom(pids) end)

    print_loading_message(10)


    IO.puts "The max hop value is #{inspect GenServer.call(counter_pid,{:answer})}"

    ret_value
  end

  def hashStuff(x) do
    #returns 64 digits of nonsense
    :crypto.hash(:sha256, Float.to_string(x)) |> Base.encode16 |> String.slice(0..4) #chnage get_next_closest_entry too if you change this 
  end

  def callRandom(pids) do
    IO.puts "pids are #{inspect pids}"
    Enum.map(pids, fn p-> RealNode.connectToRandomNode(p) end)
  end

  def print_loading_message(x) do
    if x == 0 do
      x
    else
      IO.puts x
      Process.sleep(1000)
      print_loading_message(x-1)
    end
  end


end

