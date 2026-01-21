defmodule AgentTutorial.MixProject do
  use Mix.Project

  def project do
    [
      app: :agent_tutorial,
      version: "1.0.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      description: "Interactive terminal tutorial on AI agent architecture using Termite",
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {AgentTutorial.Application, []}
    ]
  end

  defp deps do
    [
      {:termite, "~> 0.3.0"}
    ]
  end

  defp escript do
    [main_module: AgentTutorial.CLI]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{}
    ]
  end
end
