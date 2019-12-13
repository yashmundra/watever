defmodule Twitter.Application do
  use Application


  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      
      supervisor(Twitter.Repo, []),
      
      supervisor(Twitter_backend.Endpoint, []),
      
    ]

  
    opts = [strategy: :one_for_one, name: Twitter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  
  def config_change(changed, _new, removed) do
    Twitter_backend.Endpoint.config_change(changed, removed)
    :ok
  end
end
