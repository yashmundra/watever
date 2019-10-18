defmodule Matching do
    
  def max_prefix_match_length(current_node,incoming_node) do
    #String.starts_with?(str,"prefix")

    current_node_length = String.length(current_node)

    #list of prefixes to try out
    list_of_prefixes = Enum.each(1..current_node_length, fn i -> String.slice(incoming_node, 0, i) end)

    match_status = Enum.each(list_of_prefixes, fn prefix -> String.starts_with?(current_node,prefix) end)

    #remove true from front and count them and return that
    Enum.take_while(match_status, fn x -> x end) |> Enum.count()
    
    
  end

  def get_pid_from_registry(n) do
    {:ok,p} = Registry.meta(Registry.GlobalNodeList, {:tuple,n})
    p
  end

  def decider(current_entry,incoming_entry,match_length,node_id) do
    #start with match_length+1 index and see which is closer to node's index

    
  end

end