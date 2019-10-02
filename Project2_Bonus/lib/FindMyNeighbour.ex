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
    #IO.puts "My positions are "
    #IO.inspect positions
	  {:ok,myposition} = Map.fetch(positions,myid)
	  ids_to_check = Map.delete(pid_map,myid) |> Map.keys()
	  Enum.filter(ids_to_check,fn id -> check_threshold(elem(Map.fetch(positions,id),1),myposition,0.1) end) |> Enum.map(fn id-> elem(Map.fetch(pid_map,id),1) end)
  
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
    #the torus dimensions are assumed to be from 0,0,0 to n,n,n so layers are n+1
    #myids run from 1 to n
    #IO.puts "AM i here"
    no_of_processes = Enum.count(pid_map)
    no_of_layers = no_of_processes |> :math.pow(0.333) |> round()
    layer_size = round(:math.pow(no_of_layers,2))
    
    #find x , y and z
    {x,y,z} = convert_id_to_xyz(myid,no_of_layers, layer_size)

    a1 = Enum.map(1..6, fn a-> torus_func(a,x,y,z,no_of_layers-1) end) 
    a2a = Enum.map(a1,fn {x,y,z}-> convert_xyz_to_id({x,y,z}, no_of_layers,layer_size) end) 
    #IO.puts "a2a is"
    #IO.inspect Enum.map(a2a, fn id-> Map.fetch(pid_map,id) end) |> Enum.map(fn {:ok,x} -> x end)
    Enum.map(a2a, fn id-> Map.fetch(pid_map,id) end) |> Enum.map(fn {:ok,x} -> x end)
  end

  def torus_func(a,x,y,z,n) do
    #a represent the a'th neighbour of the node in question
    case a do
    1 -> if x+1 > n do {0,y,z} else {x+1,y,z} end
    2 -> if x-1 < 0 do {n,y,z} else {x-1,y,z} end
    3 -> if y+1 > n do {x,0,z} else {x,y+1,z} end
    4 -> if y-1 < 0 do {x,n,z} else {x,y-1,z} end
    5 -> if z+1 > n do {x,y,0} else {x,y,z+1} end
    6 -> if z-1 < 0 do {x,y,n} else {x,y,z-1} end
    end
  end

  def convert_id_to_xyz(myid, no_of_layers, layer_size) do
    #x and y are determined by relative id 
    # z is determined by 
    rel_id = rem(myid, layer_size+1)

    x = rem(rel_id-1,no_of_layers)

    y = div(rel_id-1,no_of_layers)
   
    z = div(myid-1,layer_size)

    {x,y,z}

  end

  def convert_xyz_to_id({x,y,z},no_of_layers,layer_size) do

    z*layer_size + y*no_of_layers + x + 1

  end

  def honeycomb(pid_map,myid) do  
    no_of_processes = Enum.count(pid_map)
    #find x and y
    {c,r} = convert_id_to_cr(myid)
    h_nebor = honey_nebors(c,r,no_of_processes)
    h_nebor = List.delete(h_nebor,0)
    Enum.map(h_nebor, fn id -> elem(Map.fetch(pid_map,id),1) end)
  end

  def convert_cr_to_id({c,r}) do
    c * 10 + r + 1
  end

  def convert_id_to_cr(myid) do
    c = div(myid - 1,10)
    r = rem(myid - 1,10)
    {c,r}
  end

  def honey_nebors(c,r,no_of_processes) do
    cond do
    c==0 and r==0 -> nebors = [nebor(c,r+1,no_of_processes)]
    c==0 and div(r,2)==0 -> nebors = [nebor(c,r+1,no_of_processes),nebor(c,r-1,no_of_processes)]
    c == 0 and div(r,2) != 0 -> nebors = [nebor(c, r+1, no_of_processes), nebor(c, r-1, no_of_processes), nebor(c+1, r, no_of_processes)]
    r == 0 and div(c,2) == 0 -> nebors = [nebor(c, r+1, no_of_processes), nebor(c-1, r, no_of_processes)]
    r == 0 and div(c,2) != 0 -> nebors = [nebor(c, r+1, no_of_processes), nebor(c+1, r, no_of_processes)]
    div(c,2) == 0 and div(r,2) == 0 -> nebors = [nebor(c, r+1, no_of_processes), nebor(c, r-1, no_of_processes), nebor(c-1, r, no_of_processes)]
    div(c,2) != 0 and div(r,2) != 0 -> nebors = [nebor(c, r+1, no_of_processes), nebor(c, r-1, no_of_processes), nebor(c-1, r, no_of_processes)]
    true -> nebors = [nebor(c, r-1, no_of_processes), nebor(c, r+1, no_of_processes), nebor(c+1, r, no_of_processes)]
    end
  end

  def nebor(c,r,no_of_processes) do
    cond do
      c>=0 and r>=0 and c*10+r+1<no_of_processes -> convert_cr_to_id{c,r}
      true -> 0
    end
  end


  def find_x_and_y(myid) do
    newid = myid - 12

    x = if rem(newid,6)==0 do 6 else rem(newid,6) end

    y = if rem(newid,6)==0 do div(newid,6) else div(newid,6) + 1 end

    {x,y}

  end

  def convert_x_y_to_id(x,y) do
    12 + (y-1)*6 + x
  end

  def honey_nebors({x,y}) do

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
    random_pid = Enum.random(Map.values(Map.delete(pid_map,myid)))
    Enum.concat(FindMyNeighbour.honeycomb(pid_map,myid),[random_pid])
  end

  def findmyneighbour(pid_map,myid,topology,positions) do

    case topology do
    "full" -> [Enum.random(FindMyNeighbour.full(pid_map,myid)),Enum.random(FindMyNeighbour.full(pid_map,myid)),Enum.random(FindMyNeighbour.full(pid_map,myid)),Enum.random(FindMyNeighbour.full(pid_map,myid)),Enum.random(FindMyNeighbour.full(pid_map,myid))]
    "line" -> Enum.random(FindMyNeighbour.line(pid_map,myid))
    "rand2D" -> Enum.random(FindMyNeighbour.rand2D(positions,pid_map,myid))
    "3Dtorus" -> [Enum.random(FindMyNeighbour.torus(pid_map,myid)),Enum.random(FindMyNeighbour.torus(pid_map,myid)),Enum.random(FindMyNeighbour.torus(pid_map,myid))]
    "honeycomb" -> [Enum.random(FindMyNeighbour.honeycomb(pid_map,myid)),Enum.random(FindMyNeighbour.honeycomb(pid_map,myid))]
    "randhoneycomb" -> Enum.random(FindMyNeighbour.randhoneycomb(pid_map,myid))
    end

  end

end
