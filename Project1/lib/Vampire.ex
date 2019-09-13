defmodule Vampire do
  def fangs(n) do
    #returns all the fangs of the number
    sz = length(Integer.digits(n))
    if rem(sz,2)!=0 do
    	[]
    else
	b = factors(n)
	#checking for all vampire conditions
	Enum.filter(b, fn {x,y} -> (length(Integer.digits(x))==div(sz,2)) && 
	                           (length(Integer.digits(y))==div(sz,2)) &&
                                   !(Enum.at(Integer.digits(x),length(Integer.digits(x))-1)===0 && Enum.at(Integer.digits(x),length(Integer.digits(x))-1)) &&
                                   (Enum.sort(Integer.digits(x)++Integer.digits(y))==Enum.sort(Integer.digits(n))) end)   
	#not both have trailing zeroes
	#digits combine to equal the number
	#if all cond'n met then add these fangs to the return value
    end
  end

  def factors(n) do
  #returns factors of n of the form {a,n/a}
  first = trunc(n / :math.pow(10, div(length(Integer.digits(n)), 2)))
  last  = :math.sqrt(n) |> round
  a = Enum.filter(first..last, fn x -> rem(n,x)==0 end)
  Enum.map(a, fn x -> {x,div(n,x)} end)
  end

  def mainfunc(n) do
    {k,v} = n
    Enum.map(k..v, fn x -> decider(x) end) |> Enum.filter(fn x -> x != :noluck end)
  end

  def decider(n) do
    x = fangs(n)
    if x != [] do
      #IO.inspect(n)
      #IO.inspect(Enum.reduce(Enum.map(x, fn {a,b} -> Integer.to_string(a)<>" "<>Integer.to_string(b) end), fn a, acc -> acc<>" "<>a end)) 
      "#{n} #{Enum.reduce(Enum.map(x, fn {a,b} -> Integer.to_string(a)<>" "<>Integer.to_string(b) end), fn a, acc -> acc<>" "<>a end)}"
    else
      :noluck
    end
  end

end
