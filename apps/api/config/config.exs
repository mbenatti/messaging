# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :api,
  namespace: Messaging.API

# Configures the endpoint
config :api, Messaging.APIWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "roa2XIdfZhzjMx7AH0UBbs8rkF0oIOqPwKGOuDZl/zE2jYOF32c04yLyDqAf38Vu",
  render_errors: [view: Messaging.APIWeb.ErrorView, accepts: ~w(json)],
  pubsub_server: Messaging.API.PubSub

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
