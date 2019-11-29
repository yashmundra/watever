defmodule MyApp do
    use Application
  
    def start(_type, _args) do
        
        Task.async fn -> Twitter_Server.start_link() end
        :timer.sleep(3000)
        no_of_clients = elem(Integer.parse(Enum.at(System.argv,0)),0)
        no_of_messages = elem(Integer.parse(Enum.at(System.argv,1)),0)
        :ets.new(:username_pid_map, [:set, :public, :named_table])
          
        simul_task = Task.async(fn -> Twitter_Misc.simulation(no_of_clients,no_of_clients,0,0,0,0,0) end)
        :global.register_name(:proc_stat,simul_task.pid)
        start_time = System.system_time(:millisecond)
  
        Twitter_Misc.creating_users(1,no_of_clients,no_of_messages)
  
        Task.await(simul_task, :infinity)
        IO.puts "Simulation time: #{System.system_time(:millisecond) - start_time} ms"
  
        receive do: (_ -> :ok)
    end 
end
  
        
        