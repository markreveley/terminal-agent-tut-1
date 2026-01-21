defmodule AgentTutorial.CLI do
  @moduledoc """
  Main CLI module for the Agent Architecture Tutorial.

  Uses Termite for terminal rendering and input handling.
  Implements a main event loop with The Elm Architecture pattern.
  """

  alias AgentTutorial.State
  alias AgentTutorial.Lessons.{Home, Lesson1, Lesson2, Lesson3, Lesson4, Lesson5}

  def main(_args \\ []) do
    # Start the application (state management)
    {:ok, _} = Application.ensure_all_started(:agent_tutorial)

    # Initialize terminal
    term = Termite.Terminal.start()
    |> Termite.Screen.alt_screen()
    |> Termite.Screen.clear_screen()

    # Run the main loop
    loop(term)
  end

  defp loop(term) do
    # Get current state
    state = State.get_state()

    # Render current view
    view = render_view(state)

    # Display the view
    term
    |> Termite.Screen.cursor_position(0, 0)
    |> Termite.Screen.clear_screen()
    |> Termite.Screen.write(view)

    # Poll for input (100ms timeout for responsive feel)
    case Termite.Terminal.poll(term, 100) do
      {:data, input} ->
        case handle_input(input, state) do
          :quit ->
            cleanup_and_exit(term)

          :continue ->
            loop(term)
        end

      :timeout ->
        # No input, continue loop (allows for animations if needed)
        loop(term)

      {:signal, :winch} ->
        # Terminal resize - just redraw
        loop(term)

      _ ->
        loop(term)
    end
  end

  defp render_view(state) do
    case state.screen do
      :home ->
        Home.render()

      {:lesson, 1} ->
        Lesson1.render(state.step)

      {:lesson, 2} ->
        Lesson2.render(state.step)

      {:lesson, 3} ->
        Lesson3.render(state.step)

      {:lesson, 4} ->
        Lesson4.render(state.step)

      {:lesson, 5} ->
        Lesson5.render(state.step, state.selected_track)

      :complete ->
        render_completion()

      _ ->
        Home.render()
    end
  end

  defp render_completion do
    """
    🎉 Tutorial Complete! 🎉

    You now understand the foundations of modern agent architecture.

    What's Next?
      • Explore ./examples/ for working code samples
      • Try building an agent with the Anthropic SDK
      • Read the full research synthesis in the docs
      • Experiment with Claude Code on your own projects

    [r] Restart tutorial  [q] Quit
    """
  end

  defp handle_input(input, state) do
    case input do
      # Quit
      "q" -> :quit
      "\e" <> "[" <> "C" -> :quit  # Sometimes escape sequences come through
      <<3>> -> :quit  # Ctrl+C

      # Navigation - Arrow keys
      "\e[C" -> # Right arrow
        handle_next(state)
        :continue

      "\e[D" -> # Left arrow
        handle_prev(state)
        :continue

      # Navigation - Letter keys
      "n" ->
        handle_next(state)
        :continue

      "p" ->
        handle_prev(state)
        :continue

      # Enter key - start from lesson 1 when on home
      "\r" ->
        if state.screen == :home do
          State.go_to_lesson(1)
        end
        :continue

      # Number keys for lesson selection
      "1" ->
        handle_number_key(1, state)
        :continue

      "2" ->
        handle_number_key(2, state)
        :continue

      "3" ->
        handle_number_key(3, state)
        :continue

      "4" ->
        if state.screen == :home do
          State.go_to_lesson(4)
        end
        :continue

      "5" ->
        if state.screen == :home do
          State.go_to_lesson(5)
        end
        :continue

      # Restart from completion
      "r" ->
        if state.screen == :complete do
          State.set_screen(:home)
        end
        :continue

      _ ->
        :continue
    end
  end

  defp handle_next(state) do
    case state.screen do
      :home ->
        State.go_to_lesson(1)

      {:lesson, _} ->
        State.next_step()

      :complete ->
        :ok  # Stay on completion
    end
  end

  defp handle_prev(state) do
    case state.screen do
      :home ->
        :ok  # Stay on home

      {:lesson, _} ->
        State.prev_step()

      :complete ->
        State.go_to_lesson(5)
    end
  end

  defp handle_number_key(num, state) do
    case state.screen do
      :home ->
        State.go_to_lesson(num)

      {:lesson, 5} when state.step == 0 ->
        # Track selection in lesson 5
        track = case num do
          1 -> :unix
          2 -> :sdk
          3 -> :beam
          _ -> nil
        end
        if track, do: State.select_track(track)

      _ ->
        :ok
    end
  end

  defp cleanup_and_exit(term) do
    term
    |> Termite.Screen.exit_alt_screen()
    |> Termite.Screen.clear_screen()
    |> Termite.Screen.cursor_position(0, 0)

    IO.puts("Thanks for using the Agent Architecture Tutorial!")
    System.halt(0)
  end
end
