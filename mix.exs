defmodule Core.Mixfile do
  use Mix.Project

  def project do
    [app: :core,
     version: "0.0.1",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Core, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex, :httpotion, :phoenix_swoosh, :timex, :quantum]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.4"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:postgrex, "~> 0.13"},
     {:phoenix_html, "~> 2.6"},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:httpotion, "~> 3.0.2"},
     {:browser, "~> 0.1.0"},
     {:stash, "~> 1.0.0"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:credo, "~> 0.8", only: [:dev, :text], runtime: false},
     {:csv, "~> 2.0.0"},
     {:hackney, "~> 1.6.0"},
     {:phoenix_swoosh, "~> 0.2"},
     {:timex, "~> 3.0"},
     {:quantum, "~> 2.0.0"},
     {:redix, ">= 0.0.0"},
     {:html_sanitize_ex, "~> 1.3.0-rc3"},
     {:geo, "~> 1.5"},
     {:topo, "~> 0.1.0"},
     {:remodel, "~> 0.0.4"},
     {:flow, "~> 0.11"},
     {:distillery, "~> 1.0.0"},
     {:number, "~> 0.5.2"},
     {:shorter_maps, "~> 2.0"}]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
    #  "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
     "test": ["test"]]
  end
end
