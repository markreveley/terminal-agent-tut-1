# The Bash→Elixir Gradient

## The Core Insight

> "The language that's hardest to write but easiest to observe beats the language that's easiest to write but hardest to observe."

In an era where agents write code, human authorship ergonomics matter less than runtime observability. The question isn't "how pleasant is this to write?" but "can I see what's happening?"

---

## The Observability Hierarchy

```
Maximum Observability ←────────────────────────→ Maximum Abstraction
        │                                                  │
        ▼                                                  ▼
     Pure Bash                                          Elixir
        │                                                  │
  Everything is visible                      Unix model preserved at scale
  State = files you can cat                  Process = can be inspected
  IPC = pipes you can tee                    State = can be examined
  Config = env you can read                  Supervision = explicit hierarchy
```

---

## Why This Order?

### Bash: The Awkward Truth

Bash is awkward to write. No complex data structures. String manipulation is painful. Error handling is verbose. But:

```bash
# State is a file
cat context.jsonl

# Process is visible
ps aux | grep myagent

# Environment is inspectable
cat /proc/$PID/environ | tr '\0' '\n'

# Communication is observable
tee debug.log
```

The "limitations" push you toward observable patterns:
- No complex data structures → state lives in files → you can `cat` it
- Awkward error handling → exit codes → you can check `$?`
- No objects → environment variables → you can `printenv`

### Elixir: Unix at Scale

When Bash can't scale (thousands of concurrent connections, complex state machines, hot code reload), Elixir preserves Unix's model:

| Unix | Elixir | Same Concept |
|------|--------|--------------|
| OS process | BEAM process | Isolated execution |
| Signals | Messages | Inter-process communication |
| systemd | Supervisor | Process supervision |
| Files | GenServer state | Inspectable state |
| Pipes | GenStage | Data transformation |

Critically, Elixir processes can be observed:
```elixir
# List all processes
Process.list()

# Inspect process state
:sys.get_state(pid)

# Trace messages
:dbg.tracer()
```

---

## When to Graduate

Start with Bash. Graduate to Elixir when you hit these walls:

### 1. Concurrency Limits

```bash
# Bash: Fork for each request (expensive)
while read request; do
  handle_request &
done

# Elixir: 100,000 lightweight processes
Enum.each(requests, fn req ->
  spawn(fn -> handle_request(req) end)
end)
```

**Graduate when:** You need more than a few dozen concurrent operations.

### 2. State Complexity

```bash
# Bash: State spread across files
cat /tmp/agent/context.json
cat /tmp/agent/tool_results/*.json
cat /tmp/agent/conversation.jsonl

# Elixir: Structured state, still inspectable
:sys.get_state(Agent)
```

**Graduate when:** File-based state becomes unwieldy.

### 3. Fault Tolerance Requirements

```bash
# Bash: Manual supervision
while true; do
  ./agent.sh
  echo "Crashed, restarting..."
  sleep 1
done

# Elixir: Declarative supervision
children = [
  {Orchestrator, []},
  {ToolRunner, []},
  {SubAgent, [id: 1]},
  {SubAgent, [id: 2]}
]
Supervisor.start_link(children, strategy: :one_for_one)
```

**Graduate when:** You need automatic restart with backoff, restart limits, or supervision trees.

### 4. Hot Code Reload

```bash
# Bash: Must restart
pkill agent && ./agent.sh

# Elixir: Update without restart
:code.load_file(MyModule)
```

**Graduate when:** You can't afford restarts.

---

## What We're NOT Using

### Node.js/JavaScript

While pleasant to write, Node.js obscures:
- Process state hidden in closures
- Async operations hard to trace
- npm dependencies create black boxes
- V8 internals not inspectable

Node.js optimizes for authorship ergonomics at the cost of observability. In the agent era, this is the wrong trade-off.

---

## The Curriculum Gradient

This curriculum follows the gradient:

### Phase 1: Unix by Doing (Bash)
Learn the primitives through observation. Every concept is something you can `ps`, `cat`, `ls`, or `strace`.

### Phase 2: Unix→Elixir Mapping
Explicitly show how each Unix primitive maps to Elixir. Not a new paradigm—the same paradigm at a different scale.

### Phase 3: Build an Agent (Both)
Start with the minimal bash agent. Identify where it struggles. Reimplement those parts in Elixir.

### Phase 4: Dissect Existing Tools
Apply the observability lens to Claude Code, Opencode. What can we see? What's hidden? How would we expose it?

---

## Key Principles

### 1. Default to Observable

When choosing between two approaches, pick the one where you can see what's happening.

### 2. Escalate, Don't Replace

Don't throw away Bash when you need Elixir. Use Elixir for the parts that need it. Shell out to Bash for the parts that don't.

### 3. State Should Be Files

Even in Elixir, consider serializing state to files for inspection:
```elixir
defp persist_state(state) do
  File.write!("state.json", Jason.encode!(state))
  state
end
```

### 4. Processes Should Be Nameable

In both Bash and Elixir, give processes meaningful names:
```bash
# Bash: Use descriptive script names
./orchestrator.sh
./tool-runner.sh

# Elixir: Register processes
Process.register(self(), :orchestrator)
```

### 5. Communication Should Be Traceable

```bash
# Bash: tee into logs
generate_response | tee -a debug.log | parse_response

# Elixir: Use tracing
:dbg.tracer()
:dbg.p(:all, :c)
```

---

## Summary

The bash→Elixir gradient isn't about "better" or "worse." It's about:

1. **Starting with maximum observability** (Bash)
2. **Identifying where that breaks down** (scale, complexity, reliability)
3. **Graduating to Elixir** while preserving the Unix mental model
4. **Never losing the ability to observe**

In an era of LLM-generated code and AI agents, this matters more than ever. We can't trial-and-error our way to understanding non-deterministic systems. We need structural observability as stable ground.
