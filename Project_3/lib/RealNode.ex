defmodule RealNode do
    use GenServer
  
    def start_link(default) do
      GenServer.start_link(__MODULE__, default) 
    end
    
    def init(state) do
      {:ok,state}
    end
  
  
    
  
    def handle_cast(msg, state) do
  
    #{:stop, :normal, {newcount, pid_map,myid,positions,topology}}
    #{:noreply, {newcount, pid_map,myid,positions,topology}}
    #GenServer.cast(addr,msg)
    end

    
  

  
  end
  
    
  
  
  