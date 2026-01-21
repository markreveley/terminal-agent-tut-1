defmodule AgentTutorial.Lessons.Lesson5 do
  @moduledoc """
  Lesson 5: Build Your Own Agent

  Three tracks for building agents: Unix, SDK, and BEAM.
  """

  alias AgentTutorial.Theme
  alias AgentTutorial.Components.UI

  @unix_agent_code """
  #!/bin/bash
  ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:?Set API key}"

  call_claude() {
    local messages="$1"
    curl -s https://api.anthropic.com/v1/messages \\
      -H "x-api-key: $ANTHROPIC_API_KEY" \\
      -H "content-type: application/json" \\
      -H "anthropic-version: 2023-06-01" \\
      -d "{
        \\"model\\": \\"claude-sonnet-4-20250514\\",
        \\"max_tokens\\": 1024,
        \\"messages\\": $messages
      }" | jq -r '.content[0].text'
  }
  """

  @sdk_agent_code """
  const client = new Anthropic();
  const tools = [{ name: "read_file", ... }];

  async function agent(task: string) {
    const messages = [{ role: "user", content: task }];

    while (true) {
      const response = await client.messages.create({
        model: "claude-sonnet-4-20250514",
        tools,
        messages
      });

      if (response.stop_reason === "end_turn") {
        return response.content[0].text;
      }

      // Execute tools and continue...
    }
  }
  """

  @beam_agent_code """
  defmodule MyAgent do
    use Jido.Agent, name: "my_agent"

    def execute(task) do
      {:ok, plan} = plan_task(task)

      plan.subtasks
      |> Task.async_stream(&execute_subtask/1,
           max_concurrency: 10)
      |> Enum.map(fn {:ok, r} -> r end)
      |> synthesize_results()
    end
  end

  # OTP supervision for fault tolerance
  Supervisor.start_link([
    {Task.Supervisor, name: TaskSupervisor},
    {MyAgent, []}
  ], strategy: :one_for_one)
  """

  def render(step, selected_track \\ nil) do
    icons = Theme.icons()

    header = UI.lesson_header(5, "Build Your Own Agent")
    nav = UI.navigation_hints([{"←/p", "Previous"}, {"→/n", "Next"}, {"q", "Quit"}])
    progress = Theme.progress_bar(step + 1, 4, 30)

    content = case step do
      0 -> render_choose_track(icons, selected_track)
      1 -> render_code(icons, selected_track)
      2 -> render_next_steps(icons, selected_track)
      3 -> render_summary(icons)
      _ -> render_choose_track(icons, selected_track)
    end

    """
    #{header}

    #{content}

    #{Theme.colored(Theme.horizontal_line(), Theme.text_dim())}

    Progress: #{progress}

    #{nav}
    """
  end

  defp render_choose_track(icons, selected_track) do
    unix_color = if selected_track == :unix, do: Theme.success(), else: Theme.text()
    sdk_color = if selected_track == :sdk, do: Theme.success(), else: Theme.text()
    beam_color = if selected_track == :beam, do: Theme.success(), else: Theme.text()

    selected_text = case selected_track do
      nil -> Theme.colored("Press 1, 2, or 3 to select a track", Theme.text_dim())
      track -> Theme.colored("Selected: #{String.upcase(to_string(track))} Track — Press → to continue", Theme.success())
    end

    """
    #{Theme.bold_colored("Choose Your Path", Theme.accent())}

    Three approaches to building agents, from simple to advanced:

      #{Theme.colored("[1]", Theme.secondary())} #{Theme.colored("#{icons.shell} Unix Track", unix_color)}
          #{Theme.colored("Build an agent using only bash, jq, and curl.", Theme.text_muted())}
          #{Theme.colored("Best for: Learning fundamentals, quick prototypes", Theme.text_dim())}

      #{Theme.colored("[2]", Theme.secondary())} #{Theme.colored("#{icons.robot} Anthropic SDK Track", sdk_color)}
          #{Theme.colored("Use the official SDK with proper tool definitions.", Theme.text_muted())}
          #{Theme.colored("Best for: Production agents, full feature access", Theme.text_dim())}

      #{Theme.colored("[3]", Theme.secondary())} #{Theme.colored("#{icons.beam} BEAM Track (Advanced)", beam_color)}
          #{Theme.colored("Orchestrate agents with Elixir/OTP supervision.", Theme.text_muted())}
          #{Theme.colored("Best for: Fault-tolerant, distributed multi-agent systems", Theme.text_dim())}

    #{selected_text}
    """
  end

  defp render_code(icons, selected_track) do
    {title, code, lang} = case selected_track do
      :unix -> {"Unix Agent (Bash)", @unix_agent_code, "bash"}
      :beam -> {"BEAM Agent (Elixir/Jido)", @beam_agent_code, "elixir"}
      _ -> {"SDK Agent (TypeScript)", @sdk_agent_code, "typescript"}
    end

    """
    #{Theme.bold_colored(title, Theme.accent())}

    #{UI.code_block(code, lang)}

    #{icons.star} #{Theme.colored("This is the core pattern. See examples/ for complete implementations.", Theme.info())}
    """
  end

  defp render_next_steps(icons, selected_track) do
    steps = case selected_track do
      :unix -> [
        "Add tool parsing with grep/sed for <tool_call> tags",
        "Implement history management with temp files",
        "Add error handling for API failures",
        "Create tool executor functions (read_file, write_file, etc.)"
      ]
      :beam -> [
        "Set up a new Phoenix/Elixir project",
        "Add Jido and configure supervisors",
        "Define agent schemas and actions",
        "Implement the Claude API integration",
        "Add LiveView for real-time UI"
      ]
      _ -> [
        "Install @anthropic-ai/sdk package",
        "Define your tool schemas",
        "Implement tool execution handlers",
        "Add context management for long conversations",
        "Consider adding memory/state persistence"
      ]
    end

    track_name = case selected_track do
      nil -> "SDK"
      t -> String.upcase(to_string(t))
    end

    steps_text = steps
    |> Enum.with_index(1)
    |> Enum.map(fn {step, i} ->
      "  #{i}. #{Theme.colored(step, Theme.text_muted())}"
    end)
    |> Enum.join("\n")

    pro_tip = UI.framed_box(
      "#{icons.star} Pro tip: Start with the simplest version that works,\n" <>
      "then add complexity only when needed. Remember the Bitter Lesson!",
      color: Theme.info()
    )

    """
    #{Theme.bold_colored("Next Steps for #{track_name} Track", Theme.accent())}

    #{steps_text}

    #{pro_tip}
    """
  end

  defp render_summary(icons) do
    thesis_box = UI.framed_box(
      "#{Theme.bold_colored("The Central Thesis:", Theme.primary())}\n\n" <>
      "\"All agents will become coding agents.\"\n\n" <>
      "The LLM + Computer architecture is exceptionally powerful\n" <>
      "regardless of whether your task involves writing code.",
      color: Theme.primary()
    )

    """
    #{Theme.bold_colored("#{icons.star} Congratulations!", Theme.accent())}

    You've completed the Agent Architecture Tutorial. Here's what you learned:

    #{icons.check} #{Theme.bold("Lesson 1:")} The agent loop is just a while loop
    #{icons.check} #{Theme.bold("Lesson 2:")} Context engineering is the key skill
    #{icons.check} #{Theme.bold("Lesson 3:")} Multi-agent needs central planning
    #{icons.check} #{Theme.bold("Lesson 4:")} Generic tools beat specialized ones
    #{icons.check} #{Theme.bold("Lesson 5:")} Start simple, add complexity as needed

    #{thesis_box}

    #{Theme.colored("Press → to exit, or explore the example files.", Theme.text_muted())}
    """
  end
end
