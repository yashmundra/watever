# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :twitter,
  ecto_repos: [Twitter.Repo]

# Configures the endpoint
config :twitter, Twitter_backend.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "vMZOuxn43BYxR8qfKq6H0nmR9pGuVO1gqIfmzA8j8oMg5tf3smDIkehUyGsW2bKc",
  render_errors: [view: Twitter_backend.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Twitter.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "Twitter",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true, # optional
  secret_key: "hwd3tsR3xqBXViHAqWyrcWB7Gi4nxSmK/iDGCkEeWf1lESCoZCjRB/J75rWoBIUh",
  serializer: Twitter.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
