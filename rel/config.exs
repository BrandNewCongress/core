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
  set cookie: :"q!4YZg8(Z(Rg=9B6?UR|{3(EnNy|,h%TS3%S,5T=/[1u_lPp(p9a!7*Dg_<Dq~cY"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"Y;9|u:1N3xW)F&vVZycVl3X.$I2=B>`60F%.4(76{WC^Nv8|8]LCp=n19bQ@wC0m"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :core do
  set version: current_version(:core)
end

