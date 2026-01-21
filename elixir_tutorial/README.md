# Agent Architecture Tutorial (Elixir/Termite Version)

An interactive terminal tutorial teaching modern AI agent architecture patterns, implemented in Elixir using the Termite terminal library.

## Requirements

- Elixir 1.15+
- OTP 26+ (required by Termite)

## Installation

```bash
# Install dependencies
mix deps.get

# Build the escript
mix escript.build

# Run the tutorial
./agent_tutorial
```

Or run directly with Mix:

```bash
mix run -e "AgentTutorial.CLI.main()"
```

## Architecture

This implementation follows **The Elm Architecture** pattern:

```
┌─────────────────────────────────────────────────────┐
│                    Application                       │
├─────────────────────────────────────────────────────┤
│  State (GenServer)                                  │
│  ├── screen: :home | {:lesson, n} | :complete       │
│  ├── step: current step within lesson               │
│  └── selected_track: :unix | :sdk | :beam           │
├─────────────────────────────────────────────────────┤
│  CLI (Event Loop)                                   │
│  ├── Render view based on state                     │
│  ├── Poll for keyboard input                        │
│  └── Dispatch updates to State                      │
├─────────────────────────────────────────────────────┤
│  Lessons (Pure Render Functions)                    │
│  └── render(step) -> String                         │
├─────────────────────────────────────────────────────┤
│  Termite (Terminal I/O)                             │
│  ├── Screen manipulation                            │
│  ├── Color/style rendering                          │
│  └── Keyboard input polling                         │
└─────────────────────────────────────────────────────┘
```

## Key Differences from Node.js/Ink Version

| Aspect | Node.js/Ink | Elixir/Termite |
|--------|-------------|----------------|
| Architecture | React component tree | Elm Architecture + GenServer |
| State | React useState hooks | GenServer process |
| Rendering | Virtual DOM diffing | Direct string rendering |
| Input | useInput hook | Terminal.poll() loop |
| Concurrency | Single-threaded | BEAM processes |
| Fault Tolerance | Try/catch | OTP supervision |

## Project Structure

```
lib/
├── agent_tutorial/
│   ├── application.ex      # OTP Application
│   ├── state.ex            # State management (GenServer)
│   ├── cli.ex              # Main event loop
│   ├── theme.ex            # Colors and visual constants
│   ├── components/
│   │   └── ui.ex           # Reusable UI components
│   └── lessons/
│       ├── home.ex         # Home screen
│       ├── lesson1.ex      # The Agent Loop
│       ├── lesson2.ex      # Context Engineering
│       ├── lesson3.ex      # Multi-Agent Patterns
│       ├── lesson4.ex      # Inside Claude Code
│       └── lesson5.ex      # Build Your Own Agent
```

## BEAM-Specific Benefits

1. **Process Isolation**: State lives in a supervised GenServer
2. **Fault Tolerance**: Crashes are isolated, can restart cleanly
3. **Hot Code Reloading**: Update lessons without restarting
4. **Natural Concurrency**: Could easily add parallel demos
5. **Pattern Matching**: Clean input handling and state transitions

## Navigation

| Key | Action |
|-----|--------|
| `→` or `n` | Next step/lesson |
| `←` or `p` | Previous step/lesson |
| `1-5` | Jump to lesson (from home) |
| `Enter` | Start from Lesson 1 |
| `q` | Quit |

## Extending

To add a new lesson:

1. Create `lib/agent_tutorial/lessons/lesson6.ex`
2. Implement `render(step)` function
3. Add case clause in `cli.ex` render_view/1
4. Update `state.ex` get_max_steps/1

## License

MIT
