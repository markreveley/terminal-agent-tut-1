# Unix-Primitive Agent Architecture

An interactive curriculum teaching Unix fundamentals as the foundation for understanding and building agentic systems.

## The Thesis

**The terminal is the native mental model for agentic orchestration.**

Unix primitives (processes, files, pipes, signals, exit codes) provide:
- **Legibility**: You can always inspect what's happening
- **Observability**: `ps`, `ls`, `cat`, `strace` work on everything
- **Composability**: Small tools combine into complex workflows
- **Provenance**: You can trace cause to effect

As work increasingly means "working with agents," these properties become more relevant, not less. The correct response to AI opacity is not to accept it, but to demand legibility at the architectural level.

## The Inversion

Traditional developer ergonomics:
```
Human writes code → Code should be readable by humans
```

Agent-era ergonomics:
```
Agent writes code → Human verifies behavior → Behavior should be observable
```

This curriculum optimizes for the new bottleneck: **observability over authorship ergonomics**.

## The Gradient

```
Pure Unix ──────────────────────────────────────► Higher Abstraction
    │                                                     │
    ▼                                                     ▼
  Bash                                                 Elixir
    │                                                     │
Maximum observability                    Unix paradigm at scale
Awkward for complex logic               (processes, supervision, messages)
```

**Default to Unix/Bash.** When performance or complexity demands, **escalate to Elixir**—which preserves Unix's process model at a higher level. No other runtime abstraction.

## Curriculum Structure

### Phase 1: Unix by Doing

Learn Unix fundamentals through interactive exercises. Each lesson: *do something*, then *observe it with Unix tools*.

| Lesson | Concept | You Will Observe |
|--------|---------|------------------|
| 01 | Everything is a File | /proc, /dev, file descriptors |
| 02 | Processes | fork, exec, ps, process trees |
| 03 | Signals | SIGTERM, SIGHUP, trap |
| 04 | Pipes and Composition | stdin/stdout, pipelines, tee |
| 05 | Exit Codes | Success/failure contracts |
| 06 | Environment and State | Variables, files as state |
| 07 | Process Supervision | Job control, restart on failure |

### Phase 2: Unix → Elixir Mapping

Explicitly map Unix concepts to Elixir/BEAM equivalents. Not a new paradigm—the same paradigm at a different scale.

| Unix | Elixir | Same Concept |
|------|--------|--------------|
| OS process | BEAM process | Isolated execution unit |
| Signals | Messages | Inter-process communication |
| Pipes | GenStage/Flow | Data transformation chains |
| systemd | Supervisor | Process supervision |
| Files | GenServer + persistence | Inspectable state |

### Phase 3: Build an Agent from First Principles

Following [Ptacek's "Everyone Write an Agent"](https://fly.io/blog/everyone-write-an-agent/) as north star:

1. The irreducible agent (15 lines)
2. Adding tools as executables
3. Context as append-only files
4. Multi-turn conversation
5. Multiple agents as processes
6. Supervision and recovery

At each step: build it, then observe it with Unix tools.

### Phase 4: Dissect Existing Tools

Apply understanding to Claude Code, Opencode, and similar:

1. What processes exist when they run?
2. Where is state stored? Is it inspectable?
3. How do tools get invoked?
4. What's observable vs opaque?
5. Rebuild observable parts with Unix primitives
6. Document what remains hidden

## The Observation Toolkit

These tools transfer across all phases:

```bash
ps aux | grep [p]rocess    # What's running?
pstree -p $$               # Process hierarchy
ls -la /proc/$PID/fd       # Open file descriptors
cat /path/to/state         # Current state
tail -f /path/to/log       # Live activity
strace -f -p $PID          # System calls
lsof -p $PID               # Open files
```

The tools don't change. What you observe does.

## Why This Matters

> "If you can't see the context, you're not engineering—you're hoping."

Opaque systems create priesthoods: those who claim to understand interpret mysteries for those who don't. Unix embeds a different epistemology: **understanding comes from observation**. Anyone can become expert by watching the system work.

In an era of LLM-generated code and AI agents, this matters more:
- Non-determinism makes behavioral learning unreliable
- You can't trial-and-error your way to understanding
- Structural observability becomes the only stable ground

## Directory Structure

```
.
├── phase1-unix-fundamentals/     # Learn Unix by doing
│   ├── lesson01-everything-is-a-file/
│   ├── lesson02-processes/
│   ├── lesson03-signals/
│   ├── lesson04-pipes-composition/
│   ├── lesson05-exit-codes/
│   ├── lesson06-environment-state/
│   └── lesson07-process-supervision/
├── phase2-unix-to-elixir/        # Map concepts to BEAM
├── phase3-build-agent/           # Construct from first principles
├── phase4-dissect-existing/      # Apply lens to CC/Opencode
├── learnings/                    # Analysis and synthesis
└── examples/                     # Reference implementations
```

## Getting Started

```bash
cd phase1-unix-fundamentals/lesson01-everything-is-a-file
./lesson.sh
```

Each lesson is self-contained and teaches through doing.

## Credits

Based on research and insights from:
- [Thomas Ptacek / Fly.io](https://fly.io/blog/everyone-write-an-agent/) - Agent primitives
- [Shrivu Shankar](https://blog.sshh.io) - Multi-agent evolution
- Anthropic Engineering - Claude Code architecture
- Manus (Peak Ji) - Context engineering
- Rich Sutton - The Bitter Lesson
- The Unix tradition - Thompson, Ritchie, McIlroy

## License

MIT
