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
    case fangs(n) do
    	[] -> nil 
    	x  -> "#{n} #{Enum.reduce(Enum.map(x, fn {a,b} -> Integer.to_string(a)<>" "<>Integer.to_string(b) end), fn a, acc -> acc<>" "<>a end)}"
    end
  end
end



Supervisor.start_link([
  {Task.Supervisor, name: MySupervisor}
], strategy: :one_for_one)


stream = Task.Supervisor.async_stream(MySupervisor,min..max,Vampire, :mainfunc, [], max_concurrency: 4000)

a = Enum.filter(Enum.to_list(stream),fn {:ok,x} -> x != nil end)
b = Enum.map(a, fn {:ok,x} -> x end)
c = Enum.reduce(b, "", fn x, acc -> acc<>"\n"<>x end)
IO.puts(c)

