min = elem(Integer.parse(Enum.at(System.argv,0)),0)
max = elem(Integer.parse(Enum.at(System.argv,1)),0)

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



Supervisor.start_link([
  {Task.Supervisor, name: MySupervisor}
], strategy: :one_for_one)

#construcitng worker unit ranges
workerUnits = 30
sz = Enum.take_every(min..max, workerUnits) |> Enum.map(fn x -> {x,x+workerUnits-1} end)
new = Enum.take(sz, Enum.count(sz)-1)
{_,b} = Enum.at(new,Enum.count(new)-1)
myranges = Enum.concat(new,[{b+1,max}])


stream = Task.Supervisor.async_stream(MySupervisor,myranges,Vampire, :mainfunc, [], max_concurrency: 10)

IO.puts Enum.to_list(stream) |> Enum.filter(fn {:ok,x} -> x != [] end) |> Enum.map(fn {:ok,x} -> x end) |> Enum.map(fn x -> Enum.reduce(x,"",fn x,acc -> acc<>x<>"\n" end) end)




