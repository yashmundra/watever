defmodule TwitterWeb do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(TwitterWeb.Endpoint, []),
      # Start your own worker by calling: TwitterWeb.Worker.start_link(arg1, arg2, arg3)
      # worker(TwitterWeb.Worker, [arg1, arg2, arg3]),
    ]
    Task.start(TwitterEngine, :main, [""]) #start engine

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TwitterWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TwitterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
