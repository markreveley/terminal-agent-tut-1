# Architectural Patterns: TUI Design for Interactive Tutorials

## Overview

This document captures architectural patterns learned from building the same interactive terminal tutorial in two different technology stacks.

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

| Aspect | React/Ink | Elixir |
|--------|-----------|--------|
| Model | `useState` hooks | GenServer state struct |
| Update | Setter functions | `handle_cast` clauses |
| View | JSX components | Pure render functions |
| Trigger | Events via `useInput` | Pattern match on `poll()` |

### Key Insight

The Elm Architecture works universally for interactive applications. React hooks approximate it, while Elixir GenServers implement it more explicitly. The pattern enforces:

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

### React/Ink Approach

```tsx
// Components receive props and render JSX
function ProgressBar({ value, max, width, color }) {
  const filled = Math.round((value / max) * width);
  return (
    <Box>
      <Text color={color}>{'█'.repeat(filled)}</Text>
      <Text color="gray">{'░'.repeat(width - filled)}</Text>
    </Box>
  );
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

The component model works in both paradigms. The difference is:
- **React**: Components manage their own input/state lifecycle
- **Elixir**: Components are pure string transformations, state lives elsewhere

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

**React (implicit state machine):**
```tsx
useInput((input, key) => {
  if (screen === 'home') {
    if (key.return) goToLesson(1);
    if ('12345'.includes(input)) goToLesson(parseInt(input));
  } else if (screen.startsWith('lesson')) {
    if (key.rightArrow) nextStep();
    if (key.leftArrow) prevStep();
  }
});
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

Elixir's pattern matching makes the state machine explicit and exhaustive. React's approach is more ad-hoc but works fine for simple cases.

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

```typescript
interface Lesson {
  number: number;
  title: string;
  steps: Step[];
}

interface Step {
  render: (state: State) => View;
  maxSteps: number;
}
```

### Potential Improvement

Both implementations hardcode lesson content in code. A more flexible approach:

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

1. **Elm Architecture** for predictable state management
2. **Progressive disclosure** for manageable complexity
3. **Component composition** for reusable UI pieces
4. **State machine input** for clear navigation
5. **Theme centralization** for visual consistency
6. **Data-driven content** for maintainability

The implementation language affects ergonomics but not fundamental architecture.
