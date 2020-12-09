import Config

### Core Configs

config :core,
  message_interval: 1000

### API Configs

config :api,
  namespace: Messaging.API

config :api, Messaging.APIWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "roa2XIdfZhzjMx7AH0UBbs8rkF0oIOqPwKGOuDZl/zE2jYOF32c04yLyDqAf38Vu",
  render_errors: [view: Messaging.APIWeb.ErrorView, accepts: ~w(json)],
  pubsub_server: Messaging.API.PubSub

### Specific configs

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
