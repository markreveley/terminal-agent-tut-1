defmodule AgentTutorial.Lessons.Home do
  @moduledoc """
  Home screen for the tutorial.
  """

  alias AgentTutorial.Theme
  alias AgentTutorial.Components.UI

  @ascii_banner """
     _                    _      _             _     _ _            _
    /_\\  __ _ ___ _ _  | |_   /_\\  _ _ __| |_ (_) |_ ___ __| |_ _  _ _ _ ___
   / _ \\/ _` / -_) ' \\ |  _| / _ \\| '_/ _| ' \\| |  _/ -_) _|  _| || | '_/ -_)
  /_/ \\_\\__, \\___|_||_| \\__| /_/ \\_\\_| \\__|_||_|_|\\__\\___\\__|\\__|\\___/|_| \\___|
        |___/
  """

  @lessons [
    {1, "The Agent Loop", "Unix primitives and the core loop"},
    {2, "Context Engineering", "The new critical skill"},
    {3, "Multi-Agent Patterns", "Plan/Execute/Task architecture"},
    {4, "Inside Claude Code", "Tools, CLAUDE.md, and design"},
    {5, "Build Your Own Agent", "Three tracks to mastery"}
  ]

  @key_concepts [
    "The \"Agent-with-a-Computer\" paradigm",
    "Context engineering vs prompt engineering",
    "KV-cache optimization for 10x cost savings",
    "Plan/Execution/Task multi-agent pattern",
    "The Bitter Lesson applied to agents"
  ]

  def render do
    icons = Theme.icons()

    banner = Theme.colored(@ascii_banner, Theme.primary())

    subtitle = Theme.bold_colored("Interactive Terminal Tutorial • January 2026", Theme.accent())

    description = Theme.colored(
      "Learn modern AI agent architecture through hands-on examples.\n" <>
      "Based on research from Anthropic, Manus, Cursor, and Fly.io.",
      Theme.text()
    )

    separator = Theme.colored(Theme.horizontal_line(), Theme.text_dim())

    lessons_header = Theme.bold_colored("LESSONS", Theme.secondary())

    lessons_list = @lessons
    |> Enum.map(fn {num, title, desc} ->
      "  " <>
      Theme.colored("[#{num}]", Theme.accent()) <>
      " " <>
      Theme.colored(String.pad_trailing(title, 25), Theme.text()) <>
      Theme.colored(desc, Theme.text_muted())
    end)
    |> Enum.join("\n")

    concepts_header = Theme.bold_colored("KEY CONCEPTS YOU'LL LEARN", Theme.secondary())

    concepts_list = @key_concepts
    |> Enum.map(fn concept ->
      "  " <> icons.bullet <> " " <> Theme.colored(concept, Theme.text_muted())
    end)
    |> Enum.join("\n")

    nav_hints = UI.navigation_hints([
      {"Enter", "Start from Lesson 1"},
      {"1-5", "Jump to lesson"},
      {"q", "Quit"}
    ])

    """
    #{banner}
    #{subtitle}

    #{description}

    #{separator}

    #{lessons_header}

    #{lessons_list}

    #{separator}

    #{concepts_header}

    #{concepts_list}

    #{separator}

    #{nav_hints}
    """
  end
end
