defmodule MyApp do
  use Application

  def start(_type, _args) do
    #{:ok,pid} = GenServer.start_link(MyGenServer, [:hi], name: :My)
    #min = elem(Integer.parse(Enum.at(System.argv,0)),0)
    #max = elem(Integer.parse(Enum.at(System.argv,1)),0)
    min = System.argv
    #IO.puts GenServer.call(:My,{min,max})
    IO.puts min
    #IO.puts max
    #{:ok,pid}
  end
end

