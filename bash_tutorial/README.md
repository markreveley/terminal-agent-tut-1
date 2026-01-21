# Agent Architecture Tutorial - Pure Bash Implementation

An interactive terminal tutorial using **only bash built-ins** and ANSI escape codes. Zero external dependencies beyond a standard Unix shell.

## Quick Start

```bash
./tutorial.sh
```

That's it. No `npm install`, no `mix deps.get`, just run it.

## Requirements

- Bash 4.0+ (standard on most Linux/macOS systems)
- A terminal that supports ANSI escape codes (virtually all modern terminals)

## How It Works

The entire tutorial is a single bash script that:

1. **Uses ANSI escape codes** for colors, cursor positioning, and screen management
2. **Reads keyboard input** with `read -rsn1` for single-character capture
3. **Manages state** with simple bash variables
4. **Renders views** as functions that print formatted text
5. **Runs an event loop** that renders → reads input → updates state → repeats

### Key Techniques

```bash
# Colors via ANSI 256-color mode
fg() { echo -e "\033[38;5;${1}m"; }
C_SUCCESS=$(fg 42)  # Green

# Cursor control
clear_screen() { printf "\033[2J\033[H"; }
move_cursor() { printf "\033[%d;%dH" "$1" "$2"; }

# Alternate screen buffer (like vim)
alt_screen_on() { printf "\033[?1049h"; }
alt_screen_off() { printf "\033[?1049l"; }

# Single keypress reading with arrow key support
read_key() {
    local key
    IFS= read -rsn1 key
    if [[ "$key" == $'\e' ]]; then
        read -rsn2 -t 0.1 seq
        case "$seq" in
            '[C') key="n" ;;  # Right arrow
            '[D') key="p" ;;  # Left arrow
        esac
    fi
    echo "$key"
}
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    State (Variables)                 │
│  SCREEN="home"  STEP=0  LESSON=1  SELECTED_TRACK="" │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│                    Main Loop                         │
│  while true; do                                      │
│      render          # Draw current state            │
│      key=$(read_key) # Wait for input                │
│      handle_input    # Update state                  │
│  done                                                │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│                    Render Functions                  │
│  render_home, render_lesson1..5, render_complete    │
│  Each is a pure function that prints to stdout      │
└─────────────────────────────────────────────────────┘
```

## Navigation

| Key | Action |
|-----|--------|
| `→` or `n` | Next step/lesson |
| `←` or `p` | Previous step/lesson |
| `1-5` | Jump to lesson (from home) |
| `Enter` | Start from Lesson 1 |
| `q` | Quit |

## File Structure

```
bash_tutorial/
└── tutorial.sh    # Everything in one file (~900 lines)
```

Compare to:
- Node.js/Ink: 19 files, 59 npm packages
- Elixir/Termite: 15 files, 1 hex package

## Limitations

1. **No layout engine** - Manual spacing and alignment
2. **No component reuse** - Functions, but no object system
3. **Limited Unicode support** - Depends on terminal
4. **No async** - Blocking input only
5. **Basic error handling** - Bash is unforgiving

## When to Use Pure Bash

✅ **Good for:**
- Quick prototypes
- Zero-dependency requirement
- Learning terminal fundamentals
- Scripts that ship with tools
- Environments without Node/Elixir

❌ **Not ideal for:**
- Complex layouts
- Team projects (maintainability)
- Rich interactions
- Cross-platform GUIs

## The Unix Philosophy in Action

This implementation embodies the Unix philosophy:
- **Do one thing well** - It's a tutorial viewer, nothing more
- **Text streams** - Everything is printf/echo
- **Composability** - Could pipe output to other tools
- **Simplicity** - No build step, no dependencies

## Extending

To add a lesson:

1. Add `render_lessonN()` function
2. Update `max_steps()` case statement
3. Add case in `render()` switch
4. Update `handle_input()` navigation logic

## License

MIT
