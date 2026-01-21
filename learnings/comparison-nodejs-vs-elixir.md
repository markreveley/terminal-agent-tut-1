# Terminal TUI Comparison: Node.js/Ink vs Elixir/Termite

## Executive Summary

Building the same interactive tutorial in both Node.js (with Ink) and Elixir (with Termite) reveals fundamental differences in how these ecosystems approach terminal UI development. Neither is universally better—the choice depends on your project's requirements.

**TL;DR:**
- **Choose Node.js/Ink** for rapid prototyping, rich component ecosystem, and familiar React patterns
- **Choose Elixir/Termite** for fault tolerance, concurrent operations, and systems that need BEAM's reliability

---

## Architecture Comparison

### Node.js/Ink: Component-Based React Model

```
┌─────────────────────────────────────────────────────┐
│  App Component                                       │
│  ├── useState(screen)                               │
│  ├── useState(step)                                 │
│  └── Conditional Rendering                          │
│      ├── <Home />                                   │
│      ├── <Lesson1 />                                │
│      └── ...                                        │
├─────────────────────────────────────────────────────┤
│  Ink Runtime                                        │
│  ├── Virtual DOM diffing                            │
│  ├── Flexbox layout                                 │
│  └── ANSI rendering                                 │
└─────────────────────────────────────────────────────┘
```

**Characteristics:**
- State lives inside components (useState hooks)
- Re-renders happen automatically on state change
- Declarative JSX syntax for UI
- Flexbox-based layout system
- Input handled via useInput hook

### Elixir/Termite: Elm Architecture + Processes

```
┌─────────────────────────────────────────────────────┐
│  GenServer (State)                                  │
│  ├── Immutable state struct                         │
│  ├── handle_cast for updates                        │
│  └── handle_call for queries                        │
├─────────────────────────────────────────────────────┤
│  CLI Module (Event Loop)                            │
│  ├── render_view(state) -> String                   │
│  ├── Terminal.poll() for input                      │
│  └── Pattern match on input                         │
├─────────────────────────────────────────────────────┤
│  Termite                                            │
│  ├── Direct ANSI sequences                          │
│  ├── No layout engine                               │
│  └── Raw string output                              │
└─────────────────────────────────────────────────────┘
```

**Characteristics:**
- State isolated in a supervised process
- Explicit event loop with polling
- Pure render functions (state → string)
- Manual string formatting for layout
- Pattern matching for input handling

---

## Detailed Pros and Cons

### Node.js/Ink

#### Pros

| Advantage | Impact |
|-----------|--------|
| **Familiar React patterns** | Faster onboarding for web developers |
| **Component ecosystem** | ink-select-input, ink-spinner, ink-text-input, etc. |
| **Flexbox layout** | Easy responsive layouts without manual calculation |
| **TypeScript support** | Full type safety out of the box |
| **Hot module reload** | Fast development iteration |
| **Virtual DOM diffing** | Only changed parts re-render (efficient) |
| **NPM ecosystem** | Access to millions of packages |
| **Documentation** | Mature, well-documented library |

#### Cons

| Disadvantage | Impact |
|--------------|--------|
| **Single-threaded** | Can't easily parallelize heavy operations |
| **No built-in fault tolerance** | Errors can crash the whole app |
| **Memory management** | V8 GC pauses possible with large state |
| **Callback complexity** | Async patterns can get messy |
| **No process isolation** | State is globally mutable |
| **Dependencies** | node_modules bloat (59 packages for this project) |

### Elixir/Termite

#### Pros

| Advantage | Impact |
|-----------|--------|
| **BEAM concurrency** | True parallelism without complexity |
| **Process isolation** | One crash doesn't bring down the app |
| **OTP supervision** | Automatic restart of failed processes |
| **Pattern matching** | Clean, exhaustive input handling |
| **Immutable data** | No accidental state mutations |
| **Hot code reloading** | Update running code without restart |
| **Minimal dependencies** | Just Termite (zero transitive deps) |
| **Memory efficiency** | Processes are lightweight (~2KB) |

#### Cons

| Disadvantage | Impact |
|--------------|--------|
| **No layout engine** | Manual string formatting required |
| **Smaller ecosystem** | Fewer pre-built components |
| **Steeper learning curve** | OTP concepts take time to learn |
| **Less familiar syntax** | Not everyone knows Elixir |
| **Manual rendering** | No virtual DOM, full redraws |
| **Less documentation** | Termite is relatively new |
| **No TypeScript** | Dialyzer for types, but different |

---

## Code Comparison

### State Management

**Node.js/Ink (React hooks):**
```tsx
function App() {
  const [screen, setScreen] = useState<Screen>('home');
  const [step, setStep] = useState(0);

  const nextStep = () => {
    if (step < maxSteps - 1) {
      setStep(s => s + 1);
    } else {
      setScreen(`lesson${lesson + 1}`);
    }
  };

  return <>{screen === 'home' && <Home />}</>;
}
```

**Elixir/Termite (GenServer):**
```elixir
defmodule State do
  use GenServer

  defstruct screen: :home, step: 0

  def next_step do
    GenServer.cast(__MODULE__, :next_step)
  end

  def handle_cast(:next_step, state) do
    if state.step < max_steps - 1 do
      {:noreply, %{state | step: state.step + 1}}
    else
      {:noreply, %{state | screen: {:lesson, state.lesson + 1}, step: 0}}
    end
  end
end
```

### Input Handling

**Node.js/Ink:**
```tsx
useInput((input, key) => {
  if (key.rightArrow || input === 'n') nextStep();
  if (key.leftArrow || input === 'p') prevStep();
  if (input === 'q') process.exit(0);
});
```

**Elixir/Termite:**
```elixir
case Termite.Terminal.poll(term, 100) do
  {:data, "\e[C"} -> State.next_step(); loop(term)  # Right arrow
  {:data, "\e[D"} -> State.prev_step(); loop(term)  # Left arrow
  {:data, "n"} -> State.next_step(); loop(term)
  {:data, "p"} -> State.prev_step(); loop(term)
  {:data, "q"} -> cleanup_and_exit(term)
  :timeout -> loop(term)
end
```

### UI Components

**Node.js/Ink (JSX components):**
```tsx
<Box flexDirection="column" marginLeft={2}>
  <Text color={theme.success}>{icons.check} Task complete</Text>
  <Text color={theme.textMuted}>Description here</Text>
</Box>
```

**Elixir/Termite (String functions):**
```elixir
def check_item(title, description) do
  icons = Theme.icons()
  Theme.colored(icons.check <> " " <> title, Theme.success()) <> "\n" <>
  "     " <> Theme.colored(description, Theme.text_muted())
end
```

---

## Performance Characteristics

| Metric | Node.js/Ink | Elixir/Termite |
|--------|-------------|----------------|
| **Startup time** | ~200ms | ~500ms (BEAM boot) |
| **Memory baseline** | ~50MB | ~30MB |
| **Input latency** | <10ms | <10ms |
| **Render method** | Virtual DOM diff | Full redraw |
| **Concurrent ops** | Event loop | True parallel |

---

## When to Choose Each

### Choose Node.js/Ink When:

1. **Rapid prototyping** - JSX is fast to write
2. **Complex layouts** - Flexbox makes responsive design easy
3. **Rich interactions** - Many pre-built input components
4. **Team familiarity** - Most devs know React
5. **Web integration** - Share logic with web apps
6. **Type safety critical** - TypeScript integration is seamless

### Choose Elixir/Termite When:

1. **Long-running processes** - BEAM excels at uptime
2. **Concurrent operations** - Need true parallelism
3. **Fault tolerance required** - Crashes should be isolated
4. **Minimal dependencies** - Security/audit requirements
5. **Part of larger Elixir system** - Natural integration
6. **Hot code deployment** - Update without restart

---

## Lessons Learned

### From Building with Ink

1. **Component composition is powerful** - Breaking UI into small components is natural
2. **Flexbox has limits** - Complex layouts still need manual work
3. **useInput is elegant** - Declarative input handling works well
4. **TypeScript catches bugs** - Strong typing prevented several errors
5. **Animation is easy** - useEffect + setInterval just works

### From Building with Termite

1. **Manual layout is tedious** - String padding/alignment is error-prone
2. **Pattern matching shines** - Input handling is clean and exhaustive
3. **GenServer adds structure** - Forces good state management
4. **BEAM overhead exists** - Startup is slower than Node
5. **Documentation gaps** - Had to read source code for some features

---

## Conclusion

Both approaches successfully built the same tutorial, demonstrating that the choice is not about capability but about trade-offs:

- **Ink** optimizes for **developer experience** and **ecosystem**
- **Termite** optimizes for **reliability** and **concurrency**

For a tutorial application like this one, **Ink is the more practical choice** due to faster development and richer components. However, for a **production agent system** that needs to run for days without crashing, the **BEAM's fault tolerance makes Elixir compelling**.

The ideal might be a hybrid: use the BEAM for orchestration and reliability, but consider whether the UI layer itself benefits from that complexity.

---

## Resources

### Node.js/Ink
- [Ink Documentation](https://github.com/vadimdemedes/ink)
- [Ink Components](https://github.com/vadimdemedes/ink#components)
- [Building CLIs with Ink](https://www.twilio.com/blog/building-conference-cli-in-react)

### Elixir/Termite
- [Termite Repository](https://github.com/Gazler/termite)
- [Termite on Hex](https://hex.pm/packages/termite)
- [ElixirConf EU 2025 Talk](https://www.elixirconf.eu/talks/building-terminal-applications-with-elixir/)
- [TermUI (higher-level framework)](https://elixirforum.com/t/termui-a-direct-mode-terminal-user-interface-framework-with-components/73464)
