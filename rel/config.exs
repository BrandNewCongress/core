use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: :dev

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"l|O^aUb=,<i<CH~f<nbvT?HaU)e?`C{cm.2(|L!,N;{>^0aIt.s;>%IlcgD5qoab"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"~8ED$8Bf!D;mp4,l&Xwiyk0><%JA0%~(|<pbeMGNYVo,?,VT0v<uhiwEwYFj`=w>"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :core do
  set applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
                     :phoenix_ecto, :postgrex, :httpotion, :swoosh, :timex, :quantum,
                     :browser, :csv, :flow, :geo, :html_sanitize_ex, :redix, :remodel,
                     :stash, :topo]]
end

release :core do
  set version: current_version(:core)
end
