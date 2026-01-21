# Terminal TUI Comparison: Three Implementations

## Executive Summary

Building the same interactive tutorial in three different stacks reveals the fundamental trade-offs in terminal UI development:

| Stack | Lines of Code | Dependencies | Best For |
|-------|---------------|--------------|----------|
| **Node.js/Ink** | ~1,200 | 59 packages | Rich UIs, rapid development |
| **Elixir/Termite** | ~1,100 | 1 package | Fault tolerance, concurrency |
| **Pure Bash** | ~900 | 0 | Zero-dependency, portability |

---

## The Three Approaches

### 1. Node.js/Ink - Component-Based React

```
┌─────────────────────────────────────────┐
│  React Components (JSX)                 │
│  ├── useState for state                 │
│  ├── useInput for keyboard              │
│  └── Flexbox for layout                 │
├─────────────────────────────────────────┤
│  Ink Runtime                            │
│  └── Virtual DOM → ANSI                 │
└─────────────────────────────────────────┘
```

### 2. Elixir/Termite - Process-Based Elm Architecture

```
┌─────────────────────────────────────────┐
│  GenServer (State Process)              │
│  ├── Immutable state struct             │
│  └── Message-based updates              │
├─────────────────────────────────────────┤
│  Event Loop                             │
│  ├── Terminal.poll() for input          │
│  └── Pattern matching dispatch          │
├─────────────────────────────────────────┤
│  Termite                                │
│  └── Direct ANSI sequences              │
└─────────────────────────────────────────┘
```

### 3. Pure Bash - Functions and Variables

```
┌─────────────────────────────────────────┐
│  Global Variables (State)               │
│  └── SCREEN, STEP, LESSON               │
├─────────────────────────────────────────┤
│  While Loop                             │
│  ├── render()                           │
│  ├── read_key()                         │
│  └── handle_input()                     │
├─────────────────────────────────────────┤
│  printf/echo                            │
│  └── Raw ANSI escape codes              │
└─────────────────────────────────────────┘
```

---

## Detailed Comparison

### Startup Time

| Stack | Cold Start | Warm Start |
|-------|------------|------------|
| Bash | ~10ms | ~10ms |
| Node.js/Ink | ~200ms | ~150ms |
| Elixir/Termite | ~500ms | ~300ms |

**Winner: Bash** - No runtime to load

### Memory Usage

| Stack | Baseline | With Tutorial |
|-------|----------|---------------|
| Bash | ~2MB | ~3MB |
| Node.js | ~50MB | ~60MB |
| Elixir | ~30MB | ~35MB |

**Winner: Bash** - Shell process only

### Development Speed

| Task | Bash | Node.js/Ink | Elixir/Termite |
|------|------|-------------|----------------|
| Setup project | 0 min | 5 min | 5 min |
| Create component | Medium | Fast | Medium |
| Add keyboard handling | Manual | Built-in | Manual |
| Style text | Manual ANSI | Props | Functions |
| Debug | Hard | Easy | Medium |

**Winner: Node.js/Ink** - Familiar patterns, good tooling

### Maintainability

| Factor | Bash | Node.js/Ink | Elixir/Termite |
|--------|------|-------------|----------------|
| Type safety | None | TypeScript | Dialyzer |
| Code organization | Functions | Components | Modules |
| Testing | Difficult | Jest/RTL | ExUnit |
| Refactoring | Risky | Safe | Safe |

**Winner: Node.js/Ink** (with TypeScript)

### Reliability

| Factor | Bash | Node.js/Ink | Elixir/Termite |
|--------|------|-------------|----------------|
| Error handling | Manual | Try/catch | Supervisors |
| Process isolation | None | None | Full |
| Recovery | Crash | Crash | Restart |
| Long-running | Risky | Okay | Excellent |

**Winner: Elixir/Termite** - BEAM's fault tolerance

### Portability

| Platform | Bash | Node.js/Ink | Elixir/Termite |
|----------|------|-------------|----------------|
| Linux | ✅ Native | ✅ Node required | ✅ BEAM required |
| macOS | ✅ Native | ✅ Node required | ✅ BEAM required |
| Windows | ⚠️ WSL/Git Bash | ✅ Node required | ✅ BEAM required |
| Docker | ✅ Tiny image | ⚠️ ~200MB image | ⚠️ ~100MB image |
| Embedded | ✅ BusyBox | ❌ Too heavy | ❌ Too heavy |

**Winner: Bash** - Available everywhere

---

## Code Comparison

### State Management

**Bash:**
```bash
# Global variables
SCREEN="home"
STEP=0
LESSON=1

# Update by assignment
next_step() {
    ((STEP++))
}
```

**Node.js/Ink:**
```tsx
const [screen, setScreen] = useState('home');
const [step, setStep] = useState(0);

const nextStep = () => setStep(s => s + 1);
```

**Elixir/Termite:**
```elixir
defstruct screen: :home, step: 0

def handle_cast(:next_step, state) do
  {:noreply, %{state | step: state.step + 1}}
end
```

### Input Handling

**Bash:**
```bash
read_key() {
    IFS= read -rsn1 key
    if [[ "$key" == $'\e' ]]; then
        read -rsn2 -t 0.1 seq
        case "$seq" in
            '[C') key="n" ;;  # Right arrow
        esac
    fi
    echo "$key"
}
```

**Node.js/Ink:**
```tsx
useInput((input, key) => {
    if (key.rightArrow) nextStep();
});
```

**Elixir/Termite:**
```elixir
case Termite.Terminal.poll(term, 100) do
    {:data, "\e[C"} -> State.next_step()
end
```

### Colored Output

**Bash:**
```bash
cprint() {
    printf "\033[38;5;${1}m%s\033[0m" "$2"
}
cprint 42 "Success!"  # Green text
```

**Node.js/Ink:**
```tsx
<Text color="#10B981">Success!</Text>
```

**Elixir/Termite:**
```elixir
Termite.Style.foreground(42)
|> Termite.Style.render_to_string("Success!")
```

---

## When to Choose Each

### Choose Bash When:

1. **Zero dependencies required** - Script must run anywhere
2. **Shipping with CLI tools** - Part of a larger shell script
3. **Embedded/minimal systems** - Only bash available
4. **Quick prototypes** - Test an idea fast
5. **Learning fundamentals** - Understand how TUIs really work

### Choose Node.js/Ink When:

1. **Rich interactions** - Complex forms, animations
2. **Team development** - TypeScript, testing, familiar patterns
3. **Rapid iteration** - Hot reload, good debugging
4. **Existing Node.js project** - Natural integration
5. **Component reuse** - Build a design system

### Choose Elixir/Termite When:

1. **Long-running processes** - Days/weeks of uptime
2. **Fault tolerance critical** - Must not crash
3. **Concurrent operations** - Multiple parallel tasks
4. **Part of larger Elixir system** - Phoenix, LiveView
5. **Hot code deployment** - Update without restart

---

## The Surprising Winner: It Depends

For this specific tutorial project:

| Criterion | Winner |
|-----------|--------|
| Fastest to build | Node.js/Ink |
| Most portable | Bash |
| Most reliable | Elixir/Termite |
| Best DX | Node.js/Ink |
| Smallest footprint | Bash |
| Best for production | Depends on requirements |

### My Recommendation

**For most TUI projects: Start with Node.js/Ink**
- Fastest development
- Best tooling
- Largest community

**For scripts shipping with tools: Use Bash**
- Zero dependencies
- Universal availability

**For mission-critical systems: Consider Elixir**
- Fault tolerance
- True concurrency

---

## Key Learnings

### 1. The Architecture Is Universal

All three implementations converge on the same pattern:
```
State → Render → Input → Update → Repeat
```

This is The Elm Architecture, whether you call it that or not.

### 2. Complexity Has Costs

| Stack | Setup Cost | Runtime Cost | Maintenance Cost |
|-------|------------|--------------|------------------|
| Bash | None | None | High |
| Node.js | Medium | Medium | Low |
| Elixir | Medium | Medium | Low |

Bash has no setup cost but high maintenance cost. The frameworks have setup cost but pay dividends in maintainability.

### 3. Dependencies Are a Choice

```
Bash:    0 dependencies, 900 lines, all manual
Node.js: 59 packages, 1200 lines, lots of help
Elixir:  1 package, 1100 lines, some help
```

You're trading control for convenience. Both are valid.

### 4. Terminal Fundamentals Don't Change

Regardless of stack, you're ultimately:
- Writing ANSI escape codes
- Reading stdin character by character
- Managing a state machine

The frameworks just make these primitives more ergonomic.

---

## Resources

- [ANSI Escape Codes](https://en.wikipedia.org/wiki/ANSI_escape_code)
- [Ink Documentation](https://github.com/vadimdemedes/ink)
- [Termite on Hex](https://hex.pm/packages/termite)
- [Bash Manual](https://www.gnu.org/software/bash/manual/)
