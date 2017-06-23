defmodule Core do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Fill initial cache
    Cosmic.fetch_all

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      # supervisor(Core.Repo, []),
      # can be readded when we have a database

      # Start the endpoint when the application starts
      supervisor(Core.Endpoint, []),
      # Start your own worker by calling: Core.Worker.start_link(arg1, arg2, arg3)
      # worker(Core.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Core.Supervisor]
    Supervisor.start_link(children, opts)

    {:ok, conn} = Redix.start_link(System.get_env("REDIS_URL"), name: :redix)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Core.Endpoint.config_change(changed, removed)
    :ok
  end
end
