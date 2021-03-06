defmodule Core do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      # can be readded when we have a database

      # Start the endpoint when the application starts
      supervisor(Core.Endpoint, []),
      supervisor(Phoenix.PubSub.PG2, [:core, []]),
      worker(Cosmic, [[application: :core]]),
      worker(Redix, [Application.get_env(:core, :redis_url), [name: :redix]]),
      worker(Core.Scheduler, []),
      worker(Core.PetitionCount, []),
      worker(Ak.List, []),
      worker(Ak.Petition, []),
      worker(Ak.Signup, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Core.Supervisor]
    result = Supervisor.start_link(children, opts)

    Core.Jobs.EventCache.fetch_or_load()

    result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Core.Endpoint.config_change(changed, removed)
    :ok
  end
end
