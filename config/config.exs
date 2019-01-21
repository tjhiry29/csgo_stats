# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :csgo_stats, ecto_repos: [CsgoStats.Repo]

config :phoenix, :json_library, Jason

# Configures the endpoint
config :csgo_stats, CsgoStatsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "N/jmV4sdrToB87nvTB0MQWzjra7kjK9cwjvnXHJyYWVkl5WtY0ZS+BOGs/sVkASF",
  render_errors: [view: CsgoStatsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CsgoStats.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# TODO: re-implement exq or remove
# config :exq,
#   name: Exq,
#   host: "127.0.0.1",
#   port: 6379,
#   namespace: "exq",
#   queues: [{"demo_parsing", 10}],
#   poll_timeout: 50,
#   scheduler_poll_timeout: 200,
#   scheduler_enable: true,
#   max_retries: 5,
#   shutdown_timeout: 60000

# config :exq_ui,
#   web_port: 4040,
#   web_namespace: "",
#   server: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
