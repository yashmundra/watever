Supervisor.start_link([
  {Task.Supervisor, name: MySupervisor}
], strategy: :one_for_one)

defmodule Vampire do
  def printrandom(name) do
    :timer.sleep(1000)
    IO.puts "hi#{name}"		
  end
end


stream = Task.Supervisor.async_stream(MySupervisor,3..100000,Vampire, :printrandom, [], max_concurrency: 4000)

Enum.to_list(stream)

