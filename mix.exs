defmodule Core.Mixfile do
  use Mix.Project

  def project do
    [
      app: :core,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Core, []},
      applications: [
        :phoenix,
        :phoenix_pubsub,
        :phoenix_html,
        :cowboy,
        :logger,
        :gettext,
        :phoenix_ecto,
        :postgrex,
        :httpotion,
        :phoenix_swoosh,
        :timex,
        :quantum,
        :osdi,
        :browser,
        :csv,
        :html_sanitize_ex,
        :number,
        :stash,
        :topo,
        :maps,
        :cosmic,
        :short_maps,
        :rollbax
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.2.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:postgrex, "~> 0.13"},
      {:phoenix_html, "~> 2.6"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:httpotion, "~> 3.0.3"},
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
      {:distillery, "~> 1.0.0"},
      {:number, "~> 0.5.2"},
      {:osdi, git: "https://github.com/BrandNewCongress/osdi_ex.git"},
      {:nb, git: "https://github.com/BrandNewCongress/nb_ex.git"},
      {:poison, "~> 3.0", override: true},
      {:cipher, ">= 1.3.3"},
      {:maps, git: "https://github.com/justicedemocrats/maps_ex.git"},
      {:cosmic, git: "https://github.com/BrandNewCongress/cosmic_ex.git"},
      {:libcluster, "~> 2.0.3"},
      {:short_maps, "~> 0.1.2"},
      {:actionkit, git: "https://github.com/justicedemocrats/actionkit_ex.git"},
      {:rollbax, "~> 0.6"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["test"]
    ]
  end
end
