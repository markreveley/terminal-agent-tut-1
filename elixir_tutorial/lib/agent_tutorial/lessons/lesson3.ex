defmodule AgentTutorial.Lessons.Lesson3 do
  @moduledoc """
  Lesson 3: Multi-Agent Patterns

  Teaches when and how to use multiple agents effectively.
  """

  alias AgentTutorial.Theme
  alias AgentTutorial.Components.UI

  def render(step) do
    icons = Theme.icons()

    header = UI.lesson_header(3, "Multi-Agent Patterns")
    nav = UI.navigation_hints([{"←/p", "Previous"}, {"→/n", "Next"}, {"q", "Quit"}])
    progress = Theme.progress_bar(step + 1, 5, 30)

    content = case step do
      0 -> render_when_multi_agent(icons)
      1 -> render_plan_execute_task(icons)
      2 -> render_demo(icons)
      3 -> render_cursor_findings(icons)
      4 -> render_takeaways(icons)
      _ -> render_when_multi_agent(icons)
    end

    """
    #{header}

    #{content}

    #{Theme.colored(Theme.horizontal_line(), Theme.text_dim())}

    Progress: #{progress}

    #{nav}
    """
  end

  defp render_when_multi_agent(icons) do
    warning_box = UI.framed_box(
      "#{icons.warning} Warning: Multi-agent adds complexity. Start simple,\n" <>
      "add agents only when single-agent fails.",
      color: Theme.warning()
    )

    """
    #{icons.robot} Not every problem needs multiple agents. Understanding
    when to use them is crucial.

    #{UI.comparison_table(
      {"Single Agent", "Multi-Agent"},
      [
        {"Sequential tasks", "Parallelizable work"},
        {"Small context needs", "Large/varied contexts"},
        {"Simple workflows", "Complex coordination"},
        {"Quick iterations", "Long-running tasks"}
      ]
    )}

    #{warning_box}
    """
  end

  defp render_plan_execute_task(icons) do
    """
    #{Theme.bold_colored("The Plan/Execution/Task Pattern", Theme.accent())}

    Modern agents converge on three roles:

      #{Theme.bold_colored("#{icons.star} Plan Agent", Theme.info())}
      Discovery, mapping, generating pointers
      #{Theme.colored("Scope: Broad context, strategic decisions", Theme.text_dim())}

      #{Theme.bold_colored("#{icons.code} Execution Agent", Theme.success())}
      Builds things given a plan, writes scripts, verifies
      #{Theme.colored("Scope: Full task, hands-on implementation", Theme.text_dim())}

      #{Theme.bold_colored("#{icons.lightning} Task Agent", Theme.secondary())}
      Transient sub-agent for parallel/isolated work
      #{Theme.colored("Scope: Single chunk of work, ephemeral", Theme.text_dim())}

    #{Theme.colored("This replaces the 2024 pattern of hand-crafted \"SQL Specialist\" or \"Researcher\" subagents.", Theme.text_muted())}
    """
  end

  defp render_demo(icons) do
    """
    #{Theme.bold_colored("Demo: Process 100 Records", Theme.accent())}

    Single Agent (Sequential):
    #{Theme.progress_bar(70, 100, 40)}
    #{Theme.colored("Processing... ~5 seconds total", Theme.text_muted())}

    Plan Agent + 5 Task Agents (Parallel):
    Task 1: #{Theme.progress_bar(100, 100, 25)} #{icons.check}
    Task 2: #{Theme.progress_bar(100, 100, 25)} #{icons.check}
    Task 3: #{Theme.progress_bar(100, 100, 25)} #{icons.check}
    Task 4: #{Theme.progress_bar(100, 100, 25)} #{icons.check}
    Task 5: #{Theme.progress_bar(100, 100, 25)} #{icons.check}
    #{Theme.colored("Completed in ~1 second (5x faster!)", Theme.success())}

    #{Theme.colored("Parallelism shines when tasks are independent and context-isolated.", Theme.info())}
    """
  end

  defp render_cursor_findings(icons) do
    """
    #{Theme.bold_colored("Cursor's Multi-Agent Research", Theme.accent())}

    Cursor ran experiments with hundreds of concurrent agents working for weeks:

      #{Theme.colored("#{icons.code} Built a web browser from scratch: 1M+ lines, 1000 files", Theme.info())}

      #{Theme.colored("#{icons.cross} Dynamic coordination (self-coordinating) FAILED", Theme.error())}
        Lock contention, race conditions, chaos

      #{Theme.colored("#{icons.check} Static planning with central planner SUCCEEDED", Theme.success())}
        Single source of truth for task assignment

      #{Theme.colored("#{icons.star} Used \"judge agent\" at cycle end to decide continuation", Theme.warning())}

      #{Theme.colored("#{icons.lightning} Fresh context periodically to combat drift", Theme.info())}
    """
  end

  defp render_takeaways(icons) do
    """
    #{Theme.bold_colored("#{icons.star} Key Takeaways", Theme.accent())}

    #{UI.check_item("Central planning beats dynamic coordination", "A single planner prevents chaos in multi-agent systems.")}

    #{UI.check_item("Task agents should be ephemeral", "Spawn, execute, return results, terminate.")}

    #{UI.check_item("Fresh context prevents drift", "Long-running agents accumulate errors; reset periodically.")}

    #{UI.check_item("Judge agents validate completeness", "Separate verification from execution.")}

    #{icons.arrow} #{Theme.bold_colored("Next: Inside Claude Code", Theme.primary())}
    """
  end
end
