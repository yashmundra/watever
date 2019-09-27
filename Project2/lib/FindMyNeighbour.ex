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
	# returns the neighbouring pids to send msg to 
    no_of_processes = Enum.count(pid_map)
    no_of_layers = no_of_processes |> :math.pow(0.333) |> round()
    layer_size = :math.pow(no_of_layers,2)
  # #need to find my_layer and my_relative_id
    if rem(myid,layer_size)==0 do
     my_relative_id = layer_size
   else
    my_relative_id = rem(myid,layer_size)
   end

   if my_relative_id == layer_size do
     my_layer = div(myid,layer_size) 
   else
     my_layer = div(myid,layer_size) + 1
   end

  # #approach
  # #can we just do id+1,id+no+of+layer,next layer and prev_layer, 

  # #three cases of node : corner, face and inside the cube
  
  # # corner : (relative id 1 or layer_size or no_of_layer or layer_size-no_of_layer ) and (layer is 1 or no_of layer)
  # # face : (relative id is non corner and layer is 1 or no_of_layer) or (relative id is 2,4,6,8 and layer is non outisde)
  
  # #outside_ids = Enum.map_every(1..layer_size-no_of_layers+1, fn x -> Range.new(x,x+no_of_layers-1) end )
  
  # #if my_layer == 1 or my_layer==no_of_layer do 
  # #outside face
  # #else
  # #  if my_relative_id == 1 
  # #end

  # #for a particular relative id , we can find 2,3 or 4 neighbour on the same lvel

  #find x, y and z of a node in the lattice
  #formula
  #x-1 and x+1 if edges x-1+cuberoot , x+1 - cuberoot


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
    "rand2D" -> FindMyNeighbour.rand2D(positions,pid_map,myid)
    "3Dtorus" -> FindMyNeighbour.torus(pid_map,myid)
    "honeycomb" -> FindMyNeighbour.honeycomb(pid_map,myid)
    "randhoneycomb" -> FindMyNeighbour.randhoneycomb(pid_map,myid)
    end

  end

end
