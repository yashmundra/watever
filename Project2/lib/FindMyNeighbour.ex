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
    #convert id to c and r 
    #hardcode c and r for top and bottom 12
    #for else c and r odd 
    next_to_last_id = Enum.count(pid_map) + 1
    case myid do
      1 -> nebors = [2,4]
      2 -> nebors = [1,5]
      3 -> nebors = [4,8]
      4 -> nebors = [1,3,9]
      5 -> nebors = [2,6,10]
      6 -> nebors = [5,11]
      7 -> nebors = [8,13]
      8 -> nebors = [3,7,14]
      9 -> nebors = [4,10,15]
      10 -> nebors = [5,9,16]
      11 -> nebors = [6,12,17]
      12 -> nebors = [11,18]
      next_to_last_id-1 -> nebors = [next_to_last_id-2,next_to_last_id-4]
      next_to_last_id-2 -> nebors = [next_to_last_id-1,next_to_last_id-5]
      next_to_last_id-3 -> nebors = [next_to_last_id-4,next_to_last_id-8]
      next_to_last_id-4 -> nebors = [next_to_last_id-1,next_to_last_id-3,next_to_last_id-9]
      next_to_last_id-5 -> nebors = [next_to_last_id-2,next_to_last_id-6,next_to_last_id-10]
      next_to_last_id-6 -> nebors = [next_to_last_id-5,next_to_last_id-11]
      next_to_last_id-7 -> nebors = [next_to_last_id-8,next_to_last_id-13]
      next_to_last_id-8 -> nebors = [next_to_last_id-3,next_to_last_id-7,next_to_last_id-14]
      next_to_last_id-9 -> nebors = [next_to_last_id-4,next_to_last_id-10,next_to_last_id-15]
      next_to_last_id-10 -> nebors = [next_to_last_id-5,next_to_last_id-9,next_to_last_id-16]
      next_to_last_id-11 -> nebors = [next_to_last_id-6,next_to_last_id-12,next_to_last_id-17]
      next_to_last_id-12 -> nebors = [next_to_last_id-11,next_to_last_id-18]
      _ -> nebors = honey_nebors(find_x_and_y(myid,next_to_last_id))
      
    end

    Enum.map(nebors, fn id-> Map.fetch(pid_map,id) end)

  end

  def find_x_and_y(myid,next_to_last_id) do
    rel_id = myid - 12


  end

  def convert_x_y_to_id(x,y)

    12*

  end

  def honey_nebors(x,y) do

    #if y is odd and even and y is 1-6, x's go from 1 to 6, y's go from 1 to n
    if div(y,2)==0 do #second row
      case x do
        1 -> [convert_x_y_to_id(x,y-1),convert_x_y_to_id(x,y+1),convert_x_y_to_id(x+1,y)]
        2 -> [convert_x_y_to_id(x,y-1),convert_x_y_to_id(x,y+1),convert_x_y_to_id(x-1,y)]
        3 -> [convert_x_y_to_id(x,y-1),convert_x_y_to_id(x,y+1),convert_x_y_to_id(x+1,y)]
        4 -> [convert_x_y_to_id(x,y-1),convert_x_y_to_id(x,y+1),convert_x_y_to_id(x-1,y)]
        5 -> [convert_x_y_to_id(x,y-1),convert_x_y_to_id(x,y+1),convert_x_y_to_id(x+1,y)]
        6 -> [convert_x_y_to_id(x,y-1),convert_x_y_to_id(x,y+1),convert_x_y_to_id(x-1,y)]
      end
    else #first row
      case x do
        1 -> [convert_x_y_to_id(x,y-1),convert_x_y_to_id(x,y+1)]
        2 -> [convert_x_y_to_id(x,y-1),convert_x_y_to_id(x,y+1),convert_x_y_to_id(x+1,y)]
        3 -> [convert_x_y_to_id(x,y-1),convert_x_y_to_id(x,y+1),convert_x_y_to_id(x-1,y)]
        4 -> [convert_x_y_to_id(x,y-1),convert_x_y_to_id(x,y+1),convert_x_y_to_id(x+1,y)] 
        5 -> [convert_x_y_to_id(x,y-1),convert_x_y_to_id(x,y+1),convert_x_y_to_id(x-1,y)]
        6 -> [convert_x_y_to_id(x,y-1),convert_x_y_to_id(x,y+1)]
      end
    end

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
