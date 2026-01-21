defmodule AgentTutorial.Lessons.Lesson2 do
  @moduledoc """
  Lesson 2: Context Engineering

  Teaches the critical skill of managing context windows effectively.
  """

  alias AgentTutorial.Theme
  alias AgentTutorial.Components.UI

  def render(step) do
    icons = Theme.icons()

    header = UI.lesson_header(2, "Context Engineering")
    nav = UI.navigation_hints([{"←/p", "Previous"}, {"→/n", "Next"}, {"q", "Quit"}])
    progress = Theme.progress_bar(step + 1, 5, 30)

    content = case step do
      0 -> render_definition(icons)
      1 -> render_demo(icons)
      2 -> render_strategies(icons)
      3 -> render_kv_cache(icons)
      4 -> render_takeaways(icons)
      _ -> render_definition(icons)
    end

    """
    #{header}

    #{content}

    #{Theme.colored(Theme.horizontal_line(), Theme.text_dim())}

    Progress: #{progress}

    #{nav}
    """
  end

  defp render_definition(icons) do
    quote_box = UI.framed_box(
      "\"What configuration of context is most likely to generate\n" <>
      " our model's desired behavior?\"\n" <>
      "                                           — Anthropic",
      title: "Definition",
      color: Theme.accent()
    )

    """
    #{icons.lightning} #{Theme.bold("Context engineering")} has replaced prompt
    engineering as the primary skill for building effective agents.

    #{quote_box}

    #{Theme.colored("The context window is your most precious resource. How you fill it determines everything.", Theme.info())}
    """
  end

  defp render_demo(icons) do
    """
    #{Theme.bold_colored("Interactive Demo: Log Analysis", Theme.accent())}

    Task: Analyze a 10MB log file for error patterns.

    #{Theme.colored("Option A:", Theme.error())} Load entire file into context
    #{Theme.colored("Option B:", Theme.success())} Write a grep script to extract errors

    Context Window Comparison:

    Option A: #{Theme.progress_bar(95, 100, 30)}
             #{Theme.colored("#{icons.cross} Context overflow after 3 tool calls", Theme.error())}

    Option B: #{Theme.progress_bar(15, 100, 30)}
             #{Theme.colored("#{icons.check} 200 tokens used, can handle any log size", Theme.success())}

    #{Theme.colored("The lesson: Act on data without loading it all into context.", Theme.info())}
    """
  end

  defp render_strategies(_icons) do
    """
    #{Theme.bold_colored("Core Strategies", Theme.accent())}

    #{Theme.bold_colored("1. Progressive Disclosure", Theme.success())}
      • Start minimal, let the agent accumulate context
      • Include usage hints in tool outputs (just-in-time)
      • Use README.md files the agent reads on demand

    #{Theme.bold_colored("2. Context Indirection", Theme.success())}
      • Let agents act on data without seeing all of it
      • Write grep/awk scripts instead of loading files
      • Manus achieves 100:1 compression ratios this way

    #{Theme.bold_colored("3. Leverage Model Priors", Theme.success())}
      • Use libraries models already know (pandas, numpy)
      • Convert legacy formats to JSON/YAML on read
      • Avoid custom DSLs the model hasn't seen
    """
  end

  defp render_kv_cache(icons) do
    """
    #{Theme.bold_colored("The KV-Cache Optimization", Theme.accent())}

    Manus identifies KV-cache hit rate as #{Theme.bold_colored("the single most important metric", Theme.success())}
    for production agents.

    #{UI.comparison_table(
      {"Token Type", "Cost (Claude Sonnet)"},
      [
        {"Cached input tokens", "$0.30 / MTok"},
        {"Uncached input tokens", "$3.00 / MTok"},
        {"Savings", "10x difference!"}
      ]
    )}

    #{Theme.bold_colored("Rules for High Cache Hit Rates:", Theme.info())}
      #{icons.bullet} Keep prompt prefix stable (1 token change = cache miss)
      #{icons.bullet} Use append-only context when possible
      #{icons.bullet} Consistent tool result serialization
    """
  end

  defp render_takeaways(icons) do
    """
    #{Theme.bold_colored("#{icons.star} Key Takeaways", Theme.accent())}

    #{UI.check_item("Context is finite and precious", "Every token has a cost—both financially and cognitively.")}

    #{UI.check_item("Indirection beats inclusion", "Write scripts to process data rather than loading it all.")}

    #{UI.check_item("Cache hits = cost savings", "Stable prefixes can reduce costs by 10x.")}

    #{UI.check_item("Progressive disclosure scales", "Start small, add context only when needed.")}

    #{icons.arrow} #{Theme.bold_colored("Next: Multi-Agent Patterns", Theme.primary())}
    """
  end
end
