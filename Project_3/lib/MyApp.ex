defmodule MyApp do
  use Application

  def start(_type, _args) do
    #{:ok,pid} = GenServer.start_link(MyGenServer, [:hi], name: :My)
    
    numNodes = elem(Integer.parse(Enum.at(System.argv,0)),0)
    numRequests = elem(Integer.parse(Enum.at(System.argv,1)),0)
    #IO.puts GenServer.call(:My,{min,max})
    
    mymessages = ['hello','world','bye','shit','goddamn','duck','suck','puck','luck','tuck']

    children = [{DynamicSupervisor, strategy: :one_for_one, name: MyApp.DynamicSupervisor}]

    ret_value = Supervisor.start_link(children, strategy: :one_for_one)

    nodeid_pid_map = Enum.map(1..numNodes, fn x -> DynamicSupervisor.start_child(MyApp.DynamicSupervisor, RealNode) end) |> Enum.map(fn {:ok,x} -> x end)
    
    #Enum.each(pid_map,fn {k,v} -> GenServer.cast(v,{:initialize,pid_map,k,positions,topology}) end)
    #  IO.puts("Starting distributed communication")
    #  {:ok,process_id} = Map.fetch(pid_map,1)
    #GenServer.cast(process_id,{rumour})

    # So Myapp will have a list of messages and it will initilize a set of nodes with these messages and then find messages from each node based on 
    # how many numRequests specified . 
    # so initially we will create just a set of numNodes
    # Then publish messages to this networks by calculating hashes of objects and then finding root node ....
    # Then route messages 
    # routing table:
    # number of levels equal number of digits in the node id
    # and a node entry on level x shares a prefix of length x with the current node whose routing table it is
    # each level has slots whose number equals the base of the routes so if messages are base-16, then 16 slots
    # we are retrieving object data given a objec key of some sort
    # how routing will work:
    # each node is both an object store and a router that external application use to find objects
    # each object will have a root node and this node will store references to nodes that actually store the object
    # how root node is found :
    # objects hash value first digit is comspred with nodes value first , if empty with v + 1 and so on unquote_splicingnode with largest refix mach function_exported?

    # so we take an object , get its hash value and then find root node by comparing hash value and node ids

    #the same logic used for finding root node for object is used to find successive node during prefix routing
    
    #when we publish an object at a node, the data is stores at the node and the reference to this node is stored at the root node. so requests
    # for object are routed to root node which references a node which stores the actual data

    ret_value
  end
end

