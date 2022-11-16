# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :trello_clone_client,
  ecto_repos: [TrelloCloneClient.Repo]

# Configures the endpoint
config :trello_clone_client, TrelloCloneClientWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "J4bAc5KAjxHHPKStWFuwxFgN0Tgm62dFsRhQnkMX/plC6xA9XX25RCHrgMV4j39P",
  render_errors: [view: TrelloCloneClientWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TrelloCloneClient.PubSub,
  live_view: [signing_salt: "CLy5v6d+"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tesla, adapter: Tesla.Adapter.Hackney

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
