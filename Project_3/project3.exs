defmodule MyApp do
  use Application

  def start(_type, _args) do
    
    numNodes = elem(Integer.parse(Enum.at(System.argv,0)),0)
    numRequests = elem(Integer.parse(Enum.at(System.argv,1)),0)

    children = [{DynamicSupervisor, strategy: :one_for_one, name: MyApp.DynamicSupervisor}]

    ret_value = Supervisor.start_link(children, strategy: :one_for_one)

    pids = Enum.map(1..numNodes, fn x -> DynamicSupervisor.start_child(MyApp.DynamicSupervisor, RealNode) end) |> Enum.map(fn {:ok,x} -> x end)
    
    pid_to_nodeid_map = Enum.map(pids, fn pid -> {pid,hashStuff(pid)} end) |> Enum.into(%{})

    node_ids = Map.values(pid_to_nodeid_map)

    #initialize elixir registry 
    #registry will consist of :global key with all node ids enum as value
    #and nodeid keys with their pids as value
    Registry.start_link(keys: :unique, name: Registry.GlobalNodeList)
    Registry.put_meta(Registry.GlobalNodeList, :global, node_ids)
    Enum.each(pid_to_nodeid_map, fn {p,n} -> Registry.put_meta(Registry.GlobalNodeList, {:tuple,n}, p) end)
    #{:ok, "custom_value"} = Registry.meta(Registry.GlobalNodeList, :custom_key)
    #Registry.put_meta(Registry.PutMetaTest, {:tuple, :key}, "tuple_value")
    #Registry.meta(Registry.PutMetaTest, {:tuple, :key})
    #{:ok, "tuple_value"}

    #add each node one by one into the network
    #that node gets a nodeid and sends a acknowledged multicast by consulting the elixir registry for its neighbours

    #each node is called bu the client program to connect to a random node and report the number of hops back

    #max hops is printed back

    #initializing nodes with their unique id's
    Enum.each(pids, fn pid -> RealNode.initialize(pid,pid_to_nodeid_map[pid]) end)

    #asking the nodes to connect to randomNodes for numRequests times

    enum_of_enum_of_hops = Enum.map(1..numRequests, fn x-> callRandom(pids) end)


    IO.puts "The hop values are "
    IO.inspect enum_of_enum_of_hops

    

    ret_value
  end

  def hashStuff(x) do
    #returns 64 digits of nonsense
    :crypto.hash(:sha256, x) |> Base.encode16    
  end

  def callRandom(pids) do
    Enum.each(pids, fn p-> RealNode.connectToRandomNode(p) end)  
  end


end

