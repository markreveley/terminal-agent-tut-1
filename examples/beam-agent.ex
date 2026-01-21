# BEAM Track: Multi-Agent System with Elixir/OTP
# ==============================================
#
# This example demonstrates how to build a fault-tolerant
# multi-agent system using Elixir's OTP patterns.
#
# Prerequisites:
#   - Elixir 1.15+
#   - mix deps.get (after creating mix.exs)
#
# Note: This is a conceptual example. For a working implementation,
# you would need to set up a proper Elixir project with dependencies.

defmodule AgentArchitecture.Application do
  @moduledoc """
  The main application supervisor that manages all agent processes.
  """
  use Application

  def start(_type, _args) do
    children = [
      # Task supervisor for spawning ephemeral task agents
      {Task.Supervisor, name: AgentArchitecture.TaskSupervisor},

      # The planner agent - single source of truth for task assignment
      {AgentArchitecture.PlannerAgent, []},

      # Dynamic supervisor for execution agents
      {DynamicSupervisor,
       name: AgentArchitecture.ExecutionSupervisor,
       strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: AgentArchitecture.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule AgentArchitecture.PlannerAgent do
  @moduledoc """
  The Plan Agent - responsible for:
  - Analyzing complex tasks
  - Breaking them into subtasks
  - Assigning work to task agents
  - Synthesizing final results

  This follows the "central planner" pattern that Cursor found
  successful in their multi-agent experiments.
  """
  use GenServer

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def execute(task) do
    GenServer.call(__MODULE__, {:execute, task}, :infinity)
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    {:ok, %{active_tasks: %{}}}
  end

  @impl true
  def handle_call({:execute, task}, _from, state) do
    # Step 1: Analyze the task and create a plan
    plan = create_plan(task)

    # Step 2: Spawn task agents for parallel execution
    results =
      plan.subtasks
      |> Task.Supervisor.async_stream_nolink(
        AgentArchitecture.TaskSupervisor,
        &execute_subtask/1,
        max_concurrency: plan.max_concurrency,
        timeout: 60_000,
        on_timeout: :kill_task
      )
      |> Enum.map(fn
        {:ok, result} -> {:ok, result}
        {:exit, reason} -> {:error, reason}
      end)

    # Step 3: Synthesize results
    final_result = synthesize_results(results, plan)

    {:reply, final_result, state}
  end

  # Private functions

  defp create_plan(task) do
    # In a real implementation, this would call Claude to analyze
    # the task and generate a structured plan
    %{
      original_task: task,
      subtasks: decompose_task(task),
      max_concurrency: 5,
      synthesis_strategy: :merge
    }
  end

  defp decompose_task(task) do
    # Placeholder: In reality, Claude would analyze the task
    # and return a list of independent subtasks
    [
      %{id: 1, type: :research, content: "Research part 1 of: #{task}"},
      %{id: 2, type: :research, content: "Research part 2 of: #{task}"},
      %{id: 3, type: :analysis, content: "Analyze findings for: #{task}"}
    ]
  end

  defp execute_subtask(subtask) do
    # Each subtask runs in isolation with its own context
    AgentArchitecture.TaskAgent.execute(subtask)
  end

  defp synthesize_results(results, _plan) do
    successful =
      results
      |> Enum.filter(fn {status, _} -> status == :ok end)
      |> Enum.map(fn {:ok, result} -> result end)

    failed =
      results
      |> Enum.filter(fn {status, _} -> status == :error end)
      |> length()

    %{
      success: length(successful),
      failed: failed,
      results: successful
    }
  end
end

defmodule AgentArchitecture.TaskAgent do
  @moduledoc """
  Task Agent - ephemeral agents that:
  - Execute a single chunk of work
  - Have isolated context (no cross-contamination)
  - Return results and terminate

  These are spawned by the Planner and supervised by Task.Supervisor.
  """

  def execute(subtask) do
    # Simulate work with isolated context
    Process.sleep(100 + :rand.uniform(200))

    # In reality, this would:
    # 1. Build context specific to this subtask
    # 2. Call Claude with that context
    # 3. Execute any tool calls
    # 4. Return the result

    %{
      subtask_id: subtask.id,
      type: subtask.type,
      result: "Completed: #{subtask.content}",
      tokens_used: :rand.uniform(1000)
    }
  end
end

defmodule AgentArchitecture.ExecutionAgent do
  @moduledoc """
  Execution Agent - long-running agents that:
  - Implement complex multi-step tasks
  - Maintain state across tool calls
  - Can be supervised and restarted on failure

  Use DynamicSupervisor to spawn these for tasks requiring
  persistent state.
  """
  use GenServer

  defstruct [:task, :context, :history, :status]

  def start_link(task) do
    GenServer.start_link(__MODULE__, task)
  end

  def run(pid) do
    GenServer.call(pid, :run, :infinity)
  end

  @impl true
  def init(task) do
    state = %__MODULE__{
      task: task,
      context: build_initial_context(task),
      history: [],
      status: :initialized
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:run, _from, state) do
    # The agentic loop
    final_state = agent_loop(state)
    {:reply, {:ok, final_state.history}, final_state}
  end

  defp build_initial_context(task) do
    %{
      system_prompt: "You are a helpful assistant.",
      task: task,
      tools: [:read_file, :write_file, :run_command]
    }
  end

  defp agent_loop(state, iteration \\ 0) do
    if iteration >= 10 do
      %{state | status: :max_iterations}
    else
      # Call Claude (placeholder)
      response = call_llm(state)

      case response do
        {:final, text} ->
          %{state | status: :complete, history: state.history ++ [{:final, text}]}

        {:tool_use, tool_calls} ->
          # Execute tools and continue
          results = Enum.map(tool_calls, &execute_tool/1)
          new_history = state.history ++ [{:tool_use, tool_calls}, {:tool_results, results}]
          agent_loop(%{state | history: new_history}, iteration + 1)

        {:error, reason} ->
          %{state | status: {:error, reason}}
      end
    end
  end

  defp call_llm(_state) do
    # Placeholder: would call Claude API
    # For demo, randomly return final or tool use
    if :rand.uniform() > 0.7 do
      {:final, "Task completed successfully"}
    else
      {:tool_use, [%{name: :read_file, input: %{path: "example.txt"}}]}
    end
  end

  defp execute_tool(%{name: :read_file, input: %{path: path}}) do
    case File.read(path) do
      {:ok, content} -> {:ok, content}
      {:error, reason} -> {:error, "Could not read #{path}: #{reason}"}
    end
  end

  defp execute_tool(%{name: name}) do
    {:error, "Unknown tool: #{name}"}
  end
end

# Example usage (would run in iex):
#
# # Start the application
# AgentArchitecture.Application.start(:normal, [])
#
# # Execute a complex task through the planner
# result = AgentArchitecture.PlannerAgent.execute("Analyze the codebase and summarize")
# IO.inspect(result)
#
# # Or spawn an execution agent for stateful work
# {:ok, pid} = DynamicSupervisor.start_child(
#   AgentArchitecture.ExecutionSupervisor,
#   {AgentArchitecture.ExecutionAgent, "Build a new feature"}
# )
# AgentArchitecture.ExecutionAgent.run(pid)
