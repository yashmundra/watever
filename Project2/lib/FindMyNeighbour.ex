defmodule FindMyNeighbour do

  #pid_map is map having id:pid
  #ids start from 1

  def full(pid_map,myid) do
	#returns the neighbouring pids to send msg to  
  	Map.values(Map.delete(pid_map,myid))
  end

  def line(pid_map,id) do
	#returns the neighbouring pids to send msg to 
        cond do
        
	id==1 -> Map.fetch(pid_map,2) 
        id==map_size(pid_map) -> Map.fetch(pid_map,id-1) 
	true -> [Map.fetch(pid_map,id-1),Map.fetch(pid_map,id+1)]

	end      
  end

  def rand2D(positions,pid_map,myid) do
	#SPECIAL since it takes positions of other and self positions is mapping of id to position {x,y}
	#returns the neighbouring pids to send msg to 
  end

  def 3Dtorus(pid_map,id) do
	#returns the neighbouring pids to send msg to 
 
  end

  def honeycomb(pid_map,id) do
	#returns the neighbouring pids to send msg to 
  end

  def randhoneycomb(pid_map,id) do
	#returns the neighbouring pids to send msg to 
  end

end
