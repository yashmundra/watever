defmodule MyApp do
    use Application
  
    def start(_type, _args) do
        
        Task.async fn -> TwitterClone.Server.start_link() end
        :timer.sleep(3000)
        numClients = elem(Integer.parse(Enum.at(System.argv,0)),0)
        no_of_messages = elem(Integer.parse(Enum.at(System.argv,1)),0)
        disconnectClients = elem(Integer.parse(Enum.at(System.argv,2)),0)
        clientsToDisconnect = disconnectClients * (0.01) * numClients
        :ets.new(:mainregistry, [:set, :public, :named_table])
          
        convergence_task = Task.async(fn -> TwitterClone.Main.converging(numClients,numClients,0,0,0,0,0) end)
        :global.register_name(:mainproc,convergence_task.pid)
        start_time = System.system_time(:millisecond)
  
        TwitterClone.Main.createUsers(1,numClients,no_of_messages)
  
        Task.await(convergence_task, :infinity)
        IO.puts "Time taken for initial simulation to complete: #{System.system_time(:millisecond) - start_time} milliseconds"
  
        TwitterClone.Main.simulate_disconnection(numClients,clientsToDisconnect)
        receive do: (_ -> :ok)
    end 
end
  
        
        