defmodule Congress do
  Stash.load(:congress_cache, "./lib/clients/congress/congress.ets")
  @reps_by_state Stash.get(:congress_cache, "congress")

  def reps_by_state, do: @reps_by_state
end
