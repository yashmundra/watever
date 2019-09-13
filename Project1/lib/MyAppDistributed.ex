defmodule MyAppDistributed do
  use Application

  def start(_type, _args) do
    min = elem(Integer.parse(Enum.at(System.argv,0)),0)
    max = elem(Integer.parse(Enum.at(System.argv,1)),0)

    Node.connect :"remote@35.232.72.189"
    Node.connect :"remote@34.67.215.69"
    Node.connect :"remote@35.239.224.245"

    #Currently serving three workers. 
    step = Kernel.trunc((max-min)/3)
    first = {min,min + step}
    second = {min + step + 1,min + 2*step + 1}
    third = {min + 2*step + 2,max}

    task1 = Task.async(fn -> GenServer.call({:My,:"remote@35.232.72.189"},first,:infinity) end)
    task2 = Task.async(fn -> GenServer.call({:My,:"remote@34.67.215.69"},second,:infinity) end)
    task3 = Task.async(fn -> GenServer.call({:My,:"remote@35.239.224.245"},third,:infinity) end)
    a = Task.await(task1,:infinity)
    IO.puts("#{a}")
    b = Task.await(task2,:infinity)
    IO.puts("#{b}")
    c = Task.await(task3,:infinity)
    IO.puts("#{c}")

    #just to avoid warning
    children = []
    opts = [strategy: :one_for_one, name: Sample.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

