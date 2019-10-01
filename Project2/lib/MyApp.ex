defmodule MyApp do
  def main(args) do

    #{numNodes, topology, algorithm} = OptionParser.parse(args)
    {[], [numNodes, topology, algorithm], []} = OptionParser.parse(args)
    prev = System.monotonic_time(:second)
    
    {numNodes, ""} = Integer.parse(numNodes)
    rumour = "Hi"
    w = 1
    
    children = []
  	#	{DynamicSupervisor, strategy: :one_for_one, name: MyApp.DynamicSupervisor}
	  #  ]

    ret_value = Supervisor.start_link(children, strategy: :one_for_one)


    #first make sure numNodes is correct for honeycomb and torus / divisible by 6 and a cube
    numNodes =  if String.equivalent?(topology,"honeycomb") or String.equivalent?(topology,"randhoneycomb") do
                remainder = rem(numNodes,6)
                numNodes = if rem(numNodes+remainder,6)==0 do numNodes+remainder else numNodes-remainder end
                #to make calculations easy
                numNodes + 24
                else 
                  if String.equivalent?(topology,"3Dtorus") do
                    round(:math.pow(round(:math.pow(numNodes,0.3333)),3))
                  else
                    #{numNodes, ""} = Integer.parse(Enum.at(System.argv,0))
                    numNodes
                  end
                end

    IO.puts("Creating Genservers")
    pid_map = Misc.create_genservers(algorithm,numNodes)    

    IO.puts("Calculating positions")
    positions = if String.equivalent?(topology,"rand2D") do Enum.map(pid_map,fn {k,v} -> {k,{:rand.uniform(),:rand.uniform()}} end) |> Enum.into(%{}) end



    #Initializing Genservers
    if String.equivalent?(algorithm,"gossip") do #for gossip
      IO.puts("Initializing Genservers")
      #{:initialize,s,w,pid_map,myid,positions,topology}
      Enum.each(pid_map,fn {k,v} -> GenServer.cast(v,{:initialize,pid_map,k,positions,topology}) end)
      IO.puts("Starting distributed communication")
      {:ok,process_id} = Map.fetch(pid_map,1)
      GenServer.cast(process_id,{rumour})
    else #push sum
      IO.puts("Initializing Genservers")
      Enum.each(pid_map,fn {k,v} -> GenServer.cast(v,{:initialize,k,w,pid_map,k,positions,topology}) end)
      IO.puts("Starting distributed communication")
      {:ok,process_id} = Map.fetch(pid_map,1) #picking random process actor
      #IO.puts "my process id is"
      #IO.inspect process_id
      GenServer.cast(process_id,{1,1})
    end


    IO.puts("Checking for termination")
    Misc.check_for_termination(pid_map,prev)

    ret_value

  end

end

