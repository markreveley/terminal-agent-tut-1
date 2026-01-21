defmodule AgentTutorial.Application do
  @moduledoc """
  The main application module for the Agent Architecture Tutorial.
  """
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # State management for the tutorial
      {AgentTutorial.State, []}
    ]

    opts = [strategy: :one_for_one, name: AgentTutorial.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
