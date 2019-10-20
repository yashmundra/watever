defmodule Matching do
    
  def max_prefix_match_length(current_node,incoming_node) do
    #String.starts_with?(str,"prefix")

    current_node_length = String.length(current_node)

    #list of prefixes to try out
    list_of_prefixes = Enum.map(1..current_node_length, fn i -> String.slice(incoming_node, 0, i) end)

    match_status = Enum.map(list_of_prefixes, fn prefix -> String.starts_with?(current_node,prefix) end)

    #remove true from front and count them and return that
    Enum.take_while(match_status, fn x -> x end) |> Enum.count()
    
  end

  def get_pid_from_registry(n) do
    {:ok,p} = Registry.meta(Registry.GlobalNodeList, {:tuple,n})
    p
  end

  def decider(current_entry,incoming_entry,match_length,node_id) do
    #start with match_length+1 index and see which is closer to node's index

    #my_range = match_length+1..String.length(node_id)
    #match_status = Enum.each(my_range, fn i-> String.equivalent?(String.at(current_entry,i),String.at(incoming_entry,i)) end)

    #remove true from front and count them and return that
    #more_match_offset = Enum.take_while(match_status, fn x -> x end) |> Enum.count()

    #compare entry[macth_length+1+more_match_offset] and nodeid[macth_length+1+more_match_offset] and return the entry with lower distance
    current_distance = String.jaro_distance(current_entry,node_id)
    incoming_distance = String.jaro_distance(incoming_entry,node_id)

    ret_value = cond do
                current_distance <= incoming_distance -> current_entry
                true -> incoming_entry
    end

    ret_value
    
  end


  def find_closest_entry_in_routing(current_node_id,destination_node_id,routing_table) do
    #the upper prefixes are more important 
    #so compare the dest with current and see what prefix match length
    #if 2 for ex, go to 2 level and find entry for the third digit
    #interesting case , if 0 match, go to first level and find the nearest first digit match and return that

    prefix_length = max_prefix_match_length(current_node_id,destination_node_id)

    digit_for_the_row = String.at(destination_node_id,prefix_length)


    #fetching the relevant cell of the routing table
    closest_entry = Map.get(Map.get(routing_table,prefix_length),digit_for_the_row)

    #if no entry found, add 1 and try again and cycle through whole row. if whole row empty. cycle through the rows.
    if closest_entry==nil do
      non_nul_row_entry = Enum.filter(Map.values(Map.get(routing_table,prefix_length)), fn x-> x!=nil end)
      if Enum.count(non_nul_row_entry)>0 do
        Enum.random(non_nul_row_entry)
      else
        #get all node ids in routing table
        get_next_closest_entry(routing_table,prefix_length+1)
      end
    else #found closest
    {closest_entry}
    end

    
    
  end

  def get_next_closest_entry(routing_table,next_row_number) do
    #get all non nils for the row if found then return else
    #go to next row
    row = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
    
    #to cycle through all the rows
    next_row_number = rem(next_row_number,16)

    non_nul_row_entry = Enum.filter(Map.values(Map.get(routing_table,next_row_number)), fn x-> x!=nil end)

    if Enum.count(non_nul_row_entry)>0 do
      Enum.random(non_nul_row_entry)
    else
      #get all node ids in routing table
      get_next_closest_entry(routing_table,next_row_number+1)
    end
    


  end

end