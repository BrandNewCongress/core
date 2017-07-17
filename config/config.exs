# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :core,
  ecto_repos: [Core.Repo]

# Configures the endpoint
config :core, Core.Endpoint,
  url: [host: 'localhost'],
  secret_key_base: "GxtfaDIKOkay5x2k0cxuJYQPX4BEyeo9fHynynmVqtiJoDgZqM8gvXT8dSMXekhI",
  render_errors: [view: Core.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Core.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use pug
config :phoenix, :template_engines,
  haml: PhoenixHaml.Engine

# Use google_maps
config :core, goog_key: System.get_env("GOOG_GEOCODE_KEY")

# Quantum config
config :core, Core.Scheduler,
  jobs: [
    # Every 15 minutes
    {"*/15 * * * *", Core.Jobs.EventCache, :update},
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
