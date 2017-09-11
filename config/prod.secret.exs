use Mix.Config

config :osdi, Osdi.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("RDS_DB_NAME"),
  username: System.get_env("RDS_DB_USER"),
  password: System.get_env("RDS_DB_PASSWORD"),
  hostname: System.get_env("RDS_DB_HOST"),
  port: "5432",
  ssl: true,
  types: GeoExample.PostgresTypes
