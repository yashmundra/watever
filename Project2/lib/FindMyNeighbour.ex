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
	#positions is mapping of id to position {x,y}
	
	myposition = Map.fetch(positions,myid)
		
	pids_to_check = Map.delete(pid_map,myid) |> Map.keys()
	Enum.filter(pids_to_check,fn pid -> check_threshold(Map.fetch(positions,pid),myposition,0.1) end)
 
  end

  def check_threshold(pos1,pos2,threshold) do
    {x1,y1} = pos1
    {x2,y2} = pos2
    dist = :math.pow(x2-x1,2)+:math.pow(y2-y1,2)
    cond do
      dist < threshold -> true
      true -> false
    end
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
