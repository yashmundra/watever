defmodule MyApp do
  use Application

  def start(_type, _args) do
    {:ok,pid} = GenServer.start_link(MyGenServer, [:hi], name: :My)
    min = elem(Integer.parse(Enum.at(System.argv,0)),0)
    max = elem(Integer.parse(Enum.at(System.argv,1)),0)
    IO.puts GenServer.call(:My,{min,max})
    {:ok,pid}
  end
end

