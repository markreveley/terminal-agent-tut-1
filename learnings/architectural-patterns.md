# Architectural Patterns: TUI Design for Interactive Tutorials

## Overview

This document captures architectural patterns learned from building interactive terminal tutorials, with focus on Bash and Elixir implementations that prioritize observability.

## Attribution

The "Elm Architecture" (TEA) pattern referenced throughout originates from Evan Czaplicki's Elm programming language (2012). The pattern has since been adopted across many frameworks and languages, often without attribution. We note this as a demonstration of **provenance in ideas**—understanding where patterns come from is as valuable as understanding the patterns themselves.

---

## Pattern 1: The Elm Architecture (TEA)

Both implementations converge on a similar pattern, whether explicitly (Elixir) or implicitly (React):

```
┌─────────────────────────────────────────────────────┐
│                    Model (State)                     │
│  - screen: which view is active                     │
│  - step: position within current lesson             │
│  - selected_track: user's choice in lesson 5        │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│                    Update (Reducer)                  │
│  - next_step: advance or change lesson              │
│  - prev_step: go back or return home                │
│  - select_track: set the chosen path                │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│                    View (Render)                     │
│  - Pure function: state → UI                        │
│  - No side effects in rendering                     │
│  - Composable components                            │
└─────────────────────────────────────────────────────┘
```

### Implementation Comparison

| Aspect | Bash | Elixir |
|--------|------|--------|
| Model | Global variables | GenServer state struct |
| Update | Functions mutating globals | `handle_cast` clauses |
| View | Functions printing ANSI | Pure render functions |
| Trigger | `read -rsn1` in loop | Pattern match on `poll()` |

### Key Insight

The Elm Architecture works universally for interactive applications. Bash implements it implicitly through loops and global state, while Elixir GenServers implement it explicitly. The pattern enforces:

1. **Unidirectional data flow** - State changes propagate downward
2. **Predictable updates** - State transitions are explicit
3. **Testable views** - render(state) is a pure function

---

## Pattern 2: Progressive Disclosure in TUI

Both implementations use the same progressive disclosure strategy:

```
┌─────────────────────────────────────────┐
│  Level 1: Home Screen                   │
│  - Overview of all lessons              │
│  - Keyboard shortcuts                   │
│  - Just enough to start                 │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│  Level 2: Lesson Introduction           │
│  - Core concept explanation             │
│  - Why this matters                     │
│  - Navigation hints                     │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│  Level 3: Deep Dive Steps               │
│  - Code examples                        │
│  - Interactive demos                    │
│  - Detailed explanations                │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│  Level 4: Takeaways                     │
│  - Key points summary                   │
│  - Connection to next lesson            │
└─────────────────────────────────────────┘
```

### Implementation

Each lesson follows the same step structure:
- Step 0: Introduction/Overview
- Steps 1-N: Deep dive content
- Final Step: Key takeaways + transition

This mirrors how the tutorial's content teaches context engineering—start minimal, add detail on demand.

---

## Pattern 3: Component Composition

### Shared Components

Both implementations extract these reusable components:

| Component | Purpose |
|-----------|---------|
| `FramedBox` | Bordered container with title |
| `ProgressBar` | Visual progress indicator |
| `CodeBlock` | Syntax-highlighted code |
| `ComparisonTable` | Side-by-side comparison |
| `ConceptList` | Bulleted concept list |
| `NavigationHint` | Keyboard shortcut display |

### Bash Approach

```bash
# Components are functions that echo ANSI sequences
progress_bar() {
    local value=$1 max=$2 width=$3
    local filled=$((value * width / max))
    local empty=$((width - filled))
    printf "\033[32m%s\033[0m" "$(printf '█%.0s' $(seq 1 $filled))"
    printf "\033[90m%s\033[0m" "$(printf '░%.0s' $(seq 1 $empty))"
}
```

### Elixir Approach

```elixir
# Components are functions returning strings
def progress_bar(value, max, width) do
  filled = round(value / max * width)
  colored(String.duplicate("█", filled), success()) <>
  colored(String.duplicate("░", width - filled), text_dim())
end
```

### Insight

The component model works in both paradigms. The key difference:
- **Bash**: Components are functions that print directly; state is global
- **Elixir**: Components are pure string transformations; state lives in GenServer

Both approaches keep rendering observable—you can trace exactly what gets printed.

---

## Pattern 4: Input Handling State Machine

Input handling follows a state machine pattern:

```
                    ┌─────────────┐
         ┌─────────│    Home     │─────────┐
         │         └─────────────┘         │
         │ Enter/1-5      │ q             │
         ▼                │               │
┌─────────────┐           │      ┌─────────────┐
│  Lesson N   │───────────┼─────▶│    Exit     │
└─────────────┘           │      └─────────────┘
    │    ▲               │
→/n │    │ ←/p           │
    ▼    │               │
┌─────────────┐           │
│ Next Step/  │───────────┘
│ Next Lesson │
└─────────────┘
```

### Implementation

**Bash (case statement state machine):**
```bash
handle_input() {
    case "$SCREEN" in
        home)
            case "$key" in
                [1-5]) go_to_lesson "$key" ;;
                '') go_to_lesson 1 ;;
                q) exit 0 ;;
            esac
            ;;
        lesson*)
            case "$key" in
                n|'') next_step ;;
                p) prev_step ;;
                q) SCREEN="home" ;;
            esac
            ;;
    esac
}
```

**Elixir (explicit pattern matching):**
```elixir
def handle_input(input, %{screen: :home}) do
  case input do
    "\r" -> State.go_to_lesson(1)
    n when n in ~w(1 2 3 4 5) -> State.go_to_lesson(String.to_integer(n))
    "q" -> :quit
    _ -> :continue
  end
end

def handle_input(input, %{screen: {:lesson, _}}) do
  case input do
    "\e[C" -> State.next_step()
    "\e[D" -> State.prev_step()
    # ...
  end
end
```

### Insight

Both Bash's `case` statements and Elixir's pattern matching make state machines explicit and traceable. You can read the code and know exactly what state transitions are possible. This is observability at the code level.

---

## Pattern 5: Theme Centralization

Both implementations centralize visual constants:

```
┌─────────────────────────────────────────┐
│              Theme Module               │
├─────────────────────────────────────────┤
│  Colors                                 │
│  ├── primary, secondary, accent         │
│  ├── success, error, warning            │
│  └── text, textMuted, textDim           │
├─────────────────────────────────────────┤
│  Characters                             │
│  ├── Box drawing (┌ ─ ┐ │ └ ┘)         │
│  ├── Progress (█ ░)                     │
│  └── Icons (✅ ❌ → • ★)               │
├─────────────────────────────────────────┤
│  Helper Functions                       │
│  ├── colored(text, color)               │
│  ├── bold(text)                         │
│  └── progress_bar(value, max, width)    │
└─────────────────────────────────────────┘
```

### Benefits

1. **Consistency** - Same colors/icons everywhere
2. **Maintainability** - Change once, update everywhere
3. **Theming** - Easy to add dark/light mode
4. **Accessibility** - Central place for contrast adjustments

---

## Pattern 6: Lesson as Data

Each lesson follows a consistent structure that could be data-driven:

```
Lesson:
  number: integer
  title: string
  steps: list of Step

Step:
  render: function(state) -> output
  max_steps: integer
```

### Potential Improvement

Implementations can hardcode lesson content in code. A more flexible approach:

```yaml
# lessons/lesson1.yaml
number: 1
title: "The Agent Loop"
steps:
  - type: introduction
    content: "Every agent follows the same pattern..."
  - type: code_example
    language: bash
    code: |
      while true; do
        CONTEXT=$(cat prompt.txt history.txt)
        ...
  - type: takeaways
    items:
      - "Agents are loops, not magic"
      - "Context is everything"
```

This would enable:
- Non-programmers editing content
- Easy localization
- Runtime content updates

---

## Summary: Universal TUI Patterns

Regardless of technology stack, successful terminal UIs share these patterns:

1. **Elm Architecture** (Evan Czaplicki, 2012) for predictable state management
2. **Progressive disclosure** for manageable complexity
3. **Component composition** for reusable UI pieces
4. **State machine input** for clear navigation
5. **Theme centralization** for visual consistency
6. **Data-driven content** for maintainability

The implementation language affects ergonomics but not fundamental architecture. What matters more is whether the implementation preserves observability—can you see what state the system is in? Can you trace how it got there?

In Bash, this comes naturally: state is in files and variables you can inspect. In Elixir, it requires using `:sys.get_state/1` and tracing tools, but the capability is preserved. Both maintain the Unix philosophy of observable systems.
