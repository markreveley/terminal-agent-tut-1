# Bash vs Elixir: An Observability-First Comparison

## Overview

This comparison evaluates Bash and Elixir through the lens of the Unix-primitive thesis: **observability over authorship ergonomics**.

---

## The Fundamental Trade-off

| Dimension | Bash | Elixir |
|-----------|------|--------|
| Observability | Maximum | High (preserves Unix model) |
| Authorship ergonomics | Low | High |
| Concurrency | Fork-based (heavy) | BEAM processes (light) |
| Fault tolerance | Manual | Built-in supervision |
| State inspection | Files (cat, less) | :sys.get_state/1 |
| Learning curve | Steep but universal | Steep but rewarding |

---

## Detailed Comparison

### State Management

**Bash: Files as State**
```bash
# State is visible as files
echo '{"turn": 1, "content": "hello"}' >> context.jsonl

# Inspection is trivial
cat context.jsonl
tail -f context.jsonl
wc -l context.jsonl
```

**Elixir: GenServer State**
```elixir
# State lives in a process
defmodule Agent do
  use GenServer

  def init(_), do: {:ok, %{turns: [], current: nil}}

  def handle_cast({:add_turn, turn}, state) do
    {:noreply, %{state | turns: [turn | state.turns]}}
  end
end

# Inspection still possible
:sys.get_state(Agent)
```

**Verdict:** Bash state is more directly observable, but Elixir state can still be inspected and offers better structure.

### Process Supervision

**Bash: Manual Loops**
```bash
#!/bin/bash
BACKOFF=1
while true; do
    ./worker.sh
    code=$?
    if [[ $code -ne 0 ]]; then
        echo "Worker crashed ($code), waiting ${BACKOFF}s"
        sleep $BACKOFF
        BACKOFF=$((BACKOFF * 2))
        [[ $BACKOFF -gt 60 ]] && BACKOFF=60
    else
        BACKOFF=1
    fi
done
```

**Elixir: Declarative Supervision**
```elixir
children = [
  {Worker, restart: :permanent},
  {ToolRunner, restart: :transient}
]
Supervisor.start_link(children, strategy: :one_for_one)
```

**Verdict:** Elixir supervision is more sophisticated and declarative. Bash requires manual implementation but the logic is explicit and traceable.

### Concurrency

**Bash: Fork-based**
```bash
# Each background job is an OS process
for i in {1..10}; do
    process_item "$i" &
done
wait
```

**Elixir: Lightweight Processes**
```elixir
# 100,000 concurrent processes are fine
Enum.each(1..100_000, fn i ->
  spawn(fn -> process_item(i) end)
end)
```

**Verdict:** Elixir wins decisively for high-concurrency scenarios. Bash is fine for ~dozens of concurrent operations.

### Inter-Process Communication

**Bash: Pipes and Files**
```bash
# Named pipe for IPC
mkfifo /tmp/agent_pipe
producer > /tmp/agent_pipe &
consumer < /tmp/agent_pipe

# Or files
echo "command" >> /tmp/commands.fifo
inotifywait -m /tmp/commands.fifo | while read; do
    process_command
done
```

**Elixir: Message Passing**
```elixir
# Direct message passing
send(worker_pid, {:task, data})

# Receive with pattern matching
receive do
  {:task, data} -> process(data)
  {:shutdown} -> cleanup()
after
  5000 -> handle_timeout()
end
```

**Verdict:** Elixir's message passing is more ergonomic. Bash pipes are directly observable with `tee`.

### Error Handling

**Bash: Exit Codes**
```bash
set -euo pipefail

if ! result=$(call_api); then
    echo "API failed with: $result" >&2
    exit 1
fi
```

**Elixir: Pattern Matching and Supervision**
```elixir
case call_api() do
  {:ok, result} -> process(result)
  {:error, reason} -> handle_error(reason)
end

# Or let it crash, supervisor restarts
def handle_call(:risky_operation, _from, state) do
  result = do_risky_thing!()  # May crash
  {:reply, result, state}
end
```

**Verdict:** Elixir's "let it crash" philosophy is powerful for fault tolerance. Bash exit codes are simpler to trace.

---

## When to Use Each

### Stay with Bash When:

1. **Dependencies must be zero** - Script ships alone
2. **Concurrency is low** - Tens of parallel operations, not thousands
3. **State is simple** - Fits in files without complex queries
4. **Observability is paramount** - Every operation must be traceable
5. **Environment is constrained** - Only shell available

### Graduate to Elixir When:

1. **Concurrency needs grow** - Hundreds/thousands of concurrent operations
2. **Fault tolerance is critical** - System must self-heal
3. **State is complex** - Need structured queries, not just file reads
4. **Hot code reload needed** - Can't afford restarts
5. **Long-running processes** - Days/weeks of uptime expected

---

## The Hybrid Approach

Use both. Elixir can shell out to Bash:

```elixir
defmodule ToolRunner do
  def run_tool(tool, args) do
    {output, exit_code} = System.cmd("./tools/#{tool}.sh", args,
      stderr_to_stdout: true,
      into: File.stream!("tool_output.log", [:append])
    )

    case exit_code do
      0 -> {:ok, output}
      _ -> {:error, output}
    end
  end
end
```

And Bash can call Elixir:

```bash
#!/bin/bash
# Orchestrator in bash, complex processing in Elixir

result=$(elixir -e "IO.puts MyApp.process_complex_data()")
echo "$result" >> results.log
```

---

## Summary

| Need | Use |
|------|-----|
| Observable, simple, portable | Bash |
| Scalable, fault-tolerant, complex | Elixir |
| Best of both | Hybrid |

The key insight: Both preserve Unix's observability model. Bash does it natively. Elixir does it through the BEAM's process model. Neither hides state in opaque abstractions.

---

## Historical Note

This curriculum previously included a Node.js/Ink implementation. While pleasant to write, Node.js was removed from consideration because it optimizes for authorship ergonomics at the cost of observability—the wrong trade-off in the agent era.

The bash→Elixir gradient preserves observability at every point on the spectrum.
