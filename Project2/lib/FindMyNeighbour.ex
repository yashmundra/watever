defmodule FindMyNeighbour do

  #pid_map is map having id:pid
  #ids start from 1

  def full(pid_map,myid) do
	  #returns the neighbouring pids to send msg to  
    #IO.inspect(pid_map)
    Map.values(Map.delete(pid_map,myid))
  end

  def line(pid_map,myid) do
	#returns the neighbouring pids to send msg to 
    cond do
      myid==1 -> [elem(Map.fetch(pid_map,2),1)]
      myid==map_size(pid_map) -> [elem(Map.fetch(pid_map,myid-1),1)]
	    true -> [elem(Map.fetch(pid_map,myid-1),1),elem(Map.fetch(pid_map,myid+1),1)]
    end      
  end

  def rand2D(positions,pid_map,myid) do
	  #positions is mapping of id to position {x,y}
	  {:ok,myposition} = Map.fetch(positions,myid)
	  pids_to_check = Map.delete(pid_map,myid) |> Map.keys()
	  Enum.filter(pids_to_check,fn pid -> check_threshold(elem(Map.fetch(positions,pid),1),myposition,0.1) end)
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

  def torus(pid_map,myid) do
	#returns the neighbouring pids to send msg to 
 	
  end

  def honeycomb(pid_map,myid) do
	#returns the neighbouring pids to send msg to 
  end

  def randhoneycomb(pid_map,myid) do
	#returns the neighbouring pids to send msg to 
  end

  def findmyneighbour(pid_map,myid,topology,positions) do

    case topology do
    "full" -> FindMyNeighbour.full(pid_map,myid)
    "line" -> FindMyNeighbour.line(pid_map,myid)
    "rand2D" -> Enum.random(FindMyNeighbour.rand2D(positions,pid_map,myid))
    "3Dtorus" -> Enum.random(FindMyNeighbour.torus(pid_map,myid))
    "honeycomb" -> Enum.random(FindMyNeighbour.honeycomb(pid_map,myid))
    "randhoneycomb" -> Enum.random(FindMyNeighbour.randhoneycomb(pid_map,myid))
    end

  end

end
