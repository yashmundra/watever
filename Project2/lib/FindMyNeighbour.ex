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
    #the torus dimensions are assumed to be from 0,0,0 to n,n,n so layers are n+1
    #myids run from 1 to n
    no_of_processes = Enum.count(pid_map)
    no_of_layers = no_of_processes |> :math.pow(0.333) |> round()
    layer_size = :math.pow(no_of_layers,2)
    
    #find x , y and z
    {x,y,z} = convert_id_to_xyz(myid,no_of_layers, layer_size)

    Enum.map(1..6, fn a-> torus_func(a,x,y,z,no_of_layers-1) end) |> Enum.map(fn a-> convert_xyz_to_id(a, no_of_layers,layer_size) end) |> Enum.map(fn id-> Map.fetch(pid_map,id) end)
    #need to modify above to return pid not ids

  end

  def torus_func(a,x,y,z,n) do
    #a represent the a'th neighbour of the node in question
    case a do
    1 -> if x+1 > n do {0,y,z} else {x+1,y,z}
    2 -> if x-1 < 0 do {n,y,z} else {x-1,y,z}
    3 -> if y+1 > n do {x,0,z} else {x,y+1,z}
    4 -> if y-1 < 0 do {x,n,z} else {x,y-1,z}
    5 -> if z+1 > n do {x,y,0} else {x,y,z+1}
    6 -> if z-1 < 0 do {x,y,n} else {x,y,z-1}
    end
  end

  def convert_id_to_xyz(myid, no_of_layers, layer_size) do
    #x and y are determined by relative id 
    # z is determined by 
    relative_id = rem(myid, layer_size+1)

    x = rem(rel_id-1,no_of_layer)

    y = div(rel_id-1,no_of_layer)
   
    z = div(myid-1,layer_size)

    {x,y,z}

  end

  def convert_xyz_to_id({x,y,z},no_of_layers,layer_size) do

    z*layer_size + y*no_of_layers + x + 1

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
