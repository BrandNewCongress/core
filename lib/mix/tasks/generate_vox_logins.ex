defmodule Mix.Tasks.GenerateVoxLogins do
  use Mix.Task

  def run(_) do
    Core.Vox.logins_for_day()
  end
end

# Mix.Tasks.NbNameFix.run("hi")
