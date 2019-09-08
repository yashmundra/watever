min = elem(Integer.parse(Enum.at(System.argv,0)),0)
max = elem(Integer.parse(Enum.at(System.argv,1)),0)

Node.connect :yash@ip1
Node.connect :yash@ip1
Node.connect :yash@ip1

#Currently serving three workers. 
step = Kernel.trunc((max-min)/3)
first = {min,min + step}
second = {min + step + 1,min + 2*step + 1}
third = {min + 2*step + 2,max}

IO.puts GenServer.call({:My,:yash@ip1},first)
IO.puts GenServer.call({:My,:yash@ip1},second)
IO.puts GenServer.call({:My,:yash@ip1},third)
