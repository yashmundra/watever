defmodule MyAppDistributedWorker do
  use Application

  def start(_type, _args) do
    {:ok,pid} = GenServer.start_link(MyGenServer, [:hi], name: :My)
    {:ok,pid}
  end
end

