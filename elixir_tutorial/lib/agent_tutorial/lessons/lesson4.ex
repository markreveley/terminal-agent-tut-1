defmodule AgentTutorial.Lessons.Lesson4 do
  @moduledoc """
  Lesson 4: Inside Claude Code

  Explores Claude Code's architecture and design philosophy.
  """

  alias AgentTutorial.Theme
  alias AgentTutorial.Components.UI

  @claude_md_example """
  # CLAUDE.md

  ## Project Overview
  This is a Next.js e-commerce application using:
  - TypeScript with strict mode
  - Prisma for database
  - Tailwind CSS for styling

  ## Commands
  - `npm run dev` - Start development server
  - `npm run test` - Run tests

  ## Code Style
  - Use functional components with hooks
  - Prefer named exports over default exports
  """

  def render(step) do
    icons = Theme.icons()

    header = UI.lesson_header(4, "Inside Claude Code")
    nav = UI.navigation_hints([{"←/p", "Previous"}, {"→/n", "Next"}, {"q", "Quit"}])
    progress = Theme.progress_bar(step + 1, 5, 30)

    content = case step do
      0 -> render_overview(icons)
      1 -> render_core_tools(icons)
      2 -> render_claude_md(icons)
      3 -> render_bitter_lesson(icons)
      4 -> render_takeaways(icons)
      _ -> render_overview(icons)
    end

    """
    #{header}

    #{content}

    #{Theme.colored(Theme.horizontal_line(), Theme.text_dim())}

    Progress: #{progress}

    #{nav}
    """
  end

  defp render_overview(icons) do
    insight_box = UI.framed_box(
      "#{icons.lightning} Key insight: The same architecture works for coding\n" <>
      "AND non-coding tasks. Power users manage emails and\n" <>
      "todo lists with it!",
      color: Theme.info()
    )

    """
    #{icons.code} #{Theme.bold("Claude Code")} is Anthropic's official CLI for Claude—
    a reference implementation of the "Agent-with-a-Computer" paradigm.

    #{Theme.bold_colored("The Architecture:", Theme.accent())}
      #{icons.bullet} Full access to filesystem, terminal, and code execution
      #{icons.bullet} Persistent environment (not ephemeral containers)
      #{icons.bullet} Progressive disclosure via CLAUDE.md files
      #{icons.bullet} Generic tools instead of domain-specific ones

    #{insight_box}
    """
  end

  defp render_core_tools(icons) do
    """
    #{Theme.bold_colored("Core Tools", Theme.accent())}

    Claude Code has surprisingly few tools—and that's intentional:

      #{Theme.bold_colored("bash", Theme.secondary())}   — Run any terminal command
                Example: npm install, git status, pytest

      #{Theme.bold_colored("read", Theme.secondary())}   — View file contents
                Example: Read src/index.ts to understand entry point

      #{Theme.bold_colored("write", Theme.secondary())}  — Create or replace entire files
                Example: Write a new component to src/Button.tsx

      #{Theme.bold_colored("edit", Theme.secondary())}   — Surgical string replacement
                Example: Change "const x = 1" to "const x = 2"

      #{Theme.bold_colored("glob", Theme.secondary())}   — Find files by pattern
                Example: Find all *.test.ts files

      #{Theme.bold_colored("grep", Theme.secondary())}   — Search file contents
                Example: Find all uses of "useState"

    #{icons.star} #{Theme.colored("Notice: All generic Unix-style operations. No domain-specific tools.", Theme.info())}
    """
  end

  defp render_claude_md(_icons) do
    """
    #{Theme.bold_colored("The CLAUDE.md File", Theme.accent())}

    CLAUDE.md is project-specific context that Claude reads automatically.
    It's the primary mechanism for progressive disclosure.

    #{UI.code_block(@claude_md_example, "markdown")}

    #{Theme.colored("Tip: Put CLAUDE.md files in subdirectories for module-specific instructions.", Theme.info())}
    """
  end

  defp render_bitter_lesson(icons) do
    quote_box = UI.framed_box(
      "\"If model progress is the rising tide, we want to be the boat,\n" <>
      " not the pillar stuck to the seabed.\"\n" <>
      "                                        — Manus Team",
      color: Theme.warning()
    )

    """
    #{Theme.bold_colored("The Bitter Lesson Applied", Theme.accent())}

    #{quote_box}

    Boris Cherny (Claude Code creator) cited the Bitter Lesson as influencing
    the decision to keep Claude Code "unopinionated."

      #{icons.check} #{Theme.colored("Generic tools over domain-specific ones", Theme.success())}
      #{icons.check} #{Theme.colored("Let the model figure out how to use them", Theme.success())}
      #{icons.check} #{Theme.colored("Remove complexity, don't add it", Theme.success())}
      #{icons.check} #{Theme.colored("Adapt to model improvements automatically", Theme.success())}

    #{Theme.colored("Manus rebuilt their agent framework 5 times in 6 months.", Theme.text_muted())}
    #{Theme.colored("Each performance gain came from removing complexity, not adding it.", Theme.text_muted())}
    """
  end

  defp render_takeaways(icons) do
    """
    #{Theme.bold_colored("#{icons.star} Key Takeaways", Theme.accent())}

    #{UI.check_item("Fewer tools is often better", "Generic capabilities beat specialized ones.")}

    #{UI.check_item("CLAUDE.md enables progressive disclosure", "Project context on demand, not upfront.")}

    #{UI.check_item("Bet on model improvements", "Build harnesses that benefit from smarter models.")}

    #{UI.check_item("The computer IS the tool", "File system + bash + code execution = universal capability.")}

    #{icons.arrow} #{Theme.bold_colored("Next: Build Your Own Agent", Theme.primary())}
    """
  end
end
