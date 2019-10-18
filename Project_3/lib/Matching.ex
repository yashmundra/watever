defmodule Matching do
    
  def max_prefix_match_length(str1,str2) do
    #String.starts_with?(str,"prefix")
    
    prefixies = Enum.map(1..String.length(str2), fn index -> end)
    # if no match return 0 if just first letter match return 1 ....
  end

  def get_pid_from_registry(n) do
    {:ok,p} = Registry.meta(Registry.GlobalNodeList, {:tuple,n})
    p
  end

end