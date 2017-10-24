defmodule Mix.Tasks.ProduceCongressData do
  use Mix.Task
  require Logger

  def run(_) do
    Logger.info("Creating congress data")
    composite = Congress.Parser.load_reps_by_state()
    Stash.set(:congress_cache, "congress", composite)
    Stash.persist(:congress_cache, "./lib/clients/congress/congress.ets")
  end
end
