defmodule AgentTutorial.State do
  @moduledoc """
  GenServer for managing tutorial state.

  Uses The Elm Architecture pattern:
  - State is immutable data
  - Updates happen through messages
  - View is a pure function of state
  """
  use GenServer

  # State structure
  defstruct screen: :home,
            lesson: 1,
            step: 0,
            selected_track: nil,
            demo_active: false,
            demo_progress: 0

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def set_screen(screen) do
    GenServer.cast(__MODULE__, {:set_screen, screen})
  end

  def go_to_lesson(lesson) do
    GenServer.cast(__MODULE__, {:go_to_lesson, lesson})
  end

  def next_step do
    GenServer.cast(__MODULE__, :next_step)
  end

  def prev_step do
    GenServer.cast(__MODULE__, :prev_step)
  end

  def select_track(track) do
    GenServer.cast(__MODULE__, {:select_track, track})
  end

  def start_demo do
    GenServer.cast(__MODULE__, :start_demo)
  end

  def update_demo_progress(progress) do
    GenServer.cast(__MODULE__, {:update_demo_progress, progress})
  end

  def reset_demo do
    GenServer.cast(__MODULE__, :reset_demo)
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:set_screen, screen}, state) do
    {:noreply, %{state | screen: screen, step: 0}}
  end

  @impl true
  def handle_cast({:go_to_lesson, lesson}, state) do
    {:noreply, %{state | screen: {:lesson, lesson}, lesson: lesson, step: 0}}
  end

  @impl true
  def handle_cast(:next_step, state) do
    max_steps = get_max_steps(state.lesson)

    if state.step < max_steps - 1 do
      {:noreply, %{state | step: state.step + 1}}
    else
      # Move to next lesson or completion
      next_lesson = state.lesson + 1

      if next_lesson <= 5 do
        {:noreply, %{state | screen: {:lesson, next_lesson}, lesson: next_lesson, step: 0}}
      else
        {:noreply, %{state | screen: :complete}}
      end
    end
  end

  @impl true
  def handle_cast(:prev_step, state) do
    if state.step > 0 do
      {:noreply, %{state | step: state.step - 1}}
    else
      # Move to previous lesson or home
      prev_lesson = state.lesson - 1

      if prev_lesson >= 1 do
        max_steps = get_max_steps(prev_lesson)
        {:noreply, %{state | screen: {:lesson, prev_lesson}, lesson: prev_lesson, step: max_steps - 1}}
      else
        {:noreply, %{state | screen: :home}}
      end
    end
  end

  @impl true
  def handle_cast({:select_track, track}, state) do
    {:noreply, %{state | selected_track: track}}
  end

  @impl true
  def handle_cast(:start_demo, state) do
    {:noreply, %{state | demo_active: true, demo_progress: 0}}
  end

  @impl true
  def handle_cast({:update_demo_progress, progress}, state) do
    {:noreply, %{state | demo_progress: progress}}
  end

  @impl true
  def handle_cast(:reset_demo, state) do
    {:noreply, %{state | demo_active: false, demo_progress: 0}}
  end

  # Helper functions

  defp get_max_steps(lesson) do
    case lesson do
      1 -> 4  # Introduction, Core Loop, Minimal Agent, Takeaways
      2 -> 5  # Definition, Demo, Strategies, KV-Cache, Takeaways
      3 -> 5  # When Multi-Agent, Pattern, Demo, Cursor, Takeaways
      4 -> 5  # Overview, Tools, CLAUDE.md, Bitter Lesson, Takeaways
      5 -> 4  # Choose Track, Code, Next Steps, Summary
      _ -> 1
    end
  end
end
