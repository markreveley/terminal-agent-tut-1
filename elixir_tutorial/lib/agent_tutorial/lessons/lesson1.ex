defmodule AgentTutorial.Lessons.Lesson1 do
  @moduledoc """
  Lesson 1: The Agent Loop

  Teaches the fundamental while-loop pattern that all agents follow.
  """

  alias AgentTutorial.Theme
  alias AgentTutorial.Components.UI

  @agent_loop_code """
  while true; do
    # 1. Build context from prompt + history
    CONTEXT=$(cat prompt.txt history.txt)

    # 2. Send to LLM, get response
    RESPONSE=$(echo "$CONTEXT" | llm)

    # 3. Check if response contains a tool call
    if has_tool_call "$RESPONSE"; then
      # 4. Execute the tool, append result to history
      RESULT=$(execute_tool "$RESPONSE")
      echo "$RESULT" >> history.txt
    else
      # 5. No tool call = final answer
      echo "$RESPONSE"
      break
    fi
  done
  """

  @minimal_agent_code """
  #!/bin/bash
  # The simplest possible agent

  SYSTEM_PROMPT="You are a helpful assistant."

  agent() {
    local user_input="$1"

    curl -s https://api.anthropic.com/v1/messages \\
      -H "x-api-key: $ANTHROPIC_API_KEY" \\
      -H "content-type: application/json" \\
      -H "anthropic-version: 2023-06-01" \\
      -d '{
        "model": "claude-sonnet-4-20250514",
        "max_tokens": 1024,
        "system": "'"$SYSTEM_PROMPT"'",
        "messages": [{"role": "user", "content": "'"$user_input"'"}]
      }' | jq -r '.content[0].text'
  }
  """

  def render(step) do
    icons = Theme.icons()

    header = UI.lesson_header(1, "The Agent Loop")
    nav = UI.navigation_hints([{"←/p", "Previous"}, {"→/n", "Next"}, {"q", "Quit"}])
    progress = Theme.progress_bar(step + 1, 4, 30)

    content = case step do
      0 -> render_introduction(icons)
      1 -> render_core_loop(icons)
      2 -> render_minimal_agent(icons)
      3 -> render_takeaways(icons)
      _ -> render_introduction(icons)
    end

    """
    #{header}

    #{content}

    #{Theme.colored(Theme.horizontal_line(), Theme.text_dim())}

    Progress: #{progress}

    #{nav}
    """
  end

  defp render_introduction(icons) do
    """
    #{icons.robot} Every AI agent—from simple chatbots to complex autonomous
    systems—follows the same fundamental pattern.

    #{Theme.bold_colored("The Big Insight:", Theme.accent())}

      An agent is just a #{Theme.bold_colored("loop", Theme.success())} that:
      1. Gathers context
      2. Calls an LLM
      3. Executes any tool calls
      4. Repeats until done

    #{Theme.colored("That's it. Everything else is optimization and specialization.", Theme.info())}
    """
  end

  defp render_core_loop(_icons) do
    """
    #{Theme.bold_colored("The Core Loop (in Bash)", Theme.accent())}

    Here's the agentic loop expressed as a shell script:

    #{UI.code_block(@agent_loop_code, "bash")}

    #{UI.concept_list("Key Components:", [
      "Context = System prompt + Conversation history",
      "Tool calls are detected in the response",
      "History accumulates across iterations",
      "Loop exits when LLM gives a final answer"
    ])}
    """
  end

  defp render_minimal_agent(icons) do
    """
    #{Theme.bold_colored("A Real Minimal Agent", Theme.accent())}

    Here's a working agent using just curl and jq:

    #{UI.code_block(@minimal_agent_code, "bash")}

    #{icons.lightning} #{Theme.colored("This is a single-turn agent. Multi-turn agents maintain history across calls.", Theme.info())}
    """
  end

  defp render_takeaways(icons) do
    """
    #{Theme.bold_colored("#{icons.star} Key Takeaways", Theme.accent())}

    #{UI.check_item("Agents are loops, not magic", "The complexity comes from tool definitions, not the loop itself.")}

    #{UI.check_item("Context is everything", "What you put in the context window determines behavior.")}

    #{UI.check_item("Tool calls extend capabilities", "The LLM decides when to use tools; you define what's available.")}

    #{UI.check_item("History enables multi-turn reasoning", "Appending results lets the agent build on previous actions.")}

    #{icons.arrow} #{Theme.bold_colored("Next: Context Engineering—the new critical skill", Theme.primary())}
    """
  end
end
