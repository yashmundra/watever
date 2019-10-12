defmodule MyApp do
  use Application

  def start(_type, _args) do
    {:ok,pid} = GenServer.start_link(MyGenServer, [:hi], name: :My)
    min = elem(Integer.parse(Enum.at(System.argv,0)),0)
    max = elem(Integer.parse(Enum.at(System.argv,1)),0)
    IO.puts GenServer.call(:My,{min,max})
    {:ok,pid}

    #children = [{DynamicSupervisor, strategy: :one_for_one, name: MyApp.DynamicSupervisor}]

    #ret_value = Supervisor.start_link(children, strategy: :one_for_one)

    #a = Enum.map(1..numNodes, fn x -> DynamicSupervisor.start_child(MyApp.DynamicSupervisor, MyGossipActor) end) |> Enum.map(fn {:ok,x} -> x end)
    
    #      Enum.each(pid_map,fn {k,v} -> GenServer.cast(v,{:initialize,pid_map,k,positions,topology}) end)
    #  IO.puts("Starting distributed communication")
    #  {:ok,process_id} = Map.fetch(pid_map,1)
    #  GenServer.cast(process_id,{rumour})

    #ret_value
  end
end

