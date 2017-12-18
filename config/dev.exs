use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :core, Core.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [npm: ["run", "watch", cd: Path.expand("../", __DIR__)]]

# Nationbuilder API Key
config :core, nb_slug: System.get_env("NB_SLUG"), nb_token: System.get_env("NB_TOKEN")

# Use Mailgun
config :core, Core.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  api_key: System.get_env("MAILGUN_KEY"),
  domain: System.get_env("MAILGUN_DOMAIN")

config :core, Core.Vox,
  adapter: Swoosh.Adapters.Mailgun,
  api_key: System.get_env("MAILGUN_KEY"),
  domain: System.get_env("MAILGUN_DOMAIN")

config :actionkit,
  base: System.get_env("AK_BASE"),
  username: System.get_env("AK_USERNAME"),
  password: System.get_env("AK_PASSWORD")

config :osdi, Osdi.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "osdi_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432",
  types: GeoExample.PostgresTypes

# Update secret
config :core, update_secret: System.get_env("UPDATE_SECRET")

# Redis url
config :core, redis_url: System.get_env("REDIS_URL")

# Cipher
config :cipher,
  keyphrase: "testiekeyphraseforcipher",
  ivphrase: "testieivphraseforcipher",
  magic_token: "magictoken"

# Watch static and templates for browser reloading.
config :core, Core.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex|haml)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

config :core,
  proxy_base_url: "http://localhost:3000/ak",
  proxy_secret: "secret"
