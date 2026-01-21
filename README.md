# Agent Architecture Tutorial

An interactive terminal tutorial teaching modern AI agent architecture patterns, based on research from Anthropic, Manus, Cursor, and Fly.io (January 2026).

```
   _                    _      _             _     _ _            _
  /_\  __ _ ___ _ _  | |_   /_\  _ _ __| |_ (_) |_ ___ __| |_ _  _ _ _ ___
 / _ \/ _` / -_) ' \ |  _| / _ \| '_/ _| ' \| |  _/ -_) _|  _| || | '_/ -_)
/_/ \_\__, \___|_||_| \__| /_/ \_\_| \__|_||_|_|\__\___\__|\__|\___/|_| \___|
      |___/
```

## Quick Start

```bash
# Install dependencies
npm install

# Run the tutorial
npm run dev
```

## What You'll Learn

### Lesson 1: The Agent Loop
- The fundamental while-loop pattern all agents follow
- Context = System prompt + History
- Tool calls vs final responses

### Lesson 2: Context Engineering
- Why context engineering replaced prompt engineering
- Progressive disclosure patterns
- KV-cache optimization (10x cost savings)
- Context indirection for large data

### Lesson 3: Multi-Agent Patterns
- When single agents aren't enough
- Plan/Execution/Task architecture
- Central planning vs dynamic coordination
- Cursor's findings from multi-agent experiments

### Lesson 4: Inside Claude Code
- Core tools: bash, read, write, edit, glob, grep
- The CLAUDE.md file for progressive disclosure
- The Bitter Lesson applied to agent design
- Why generic tools beat specialized ones

### Lesson 5: Build Your Own Agent
Three tracks to choose from:
- **Unix Track**: Build with bash, curl, and jq
- **SDK Track**: Use the Anthropic TypeScript SDK
- **BEAM Track**: Elixir/OTP for fault-tolerant multi-agent systems

## Navigation

| Key | Action |
|-----|--------|
| `→` or `n` | Next step/lesson |
| `←` or `p` | Previous step/lesson |
| `1-5` | Jump to lesson (from home) |
| `Enter` | Start from Lesson 1 |
| `q` | Quit |

## Example Code

The `examples/` directory contains working implementations:

- `unix-agent.sh` - Complete bash agent with tools
- `sdk-agent.ts` - TypeScript SDK implementation
- `beam-agent.ex` - Elixir/OTP multi-agent system
- `sample-CLAUDE.md` - Example project configuration

## Key Concepts

### The Central Thesis
> "All agents will become coding agents."

The LLM + Computer architecture—file system, bash terminal, code generation—is exceptionally powerful regardless of whether your task involves writing code.

### The Bitter Lesson
Model improvements obsolete complex harnesses. Build systems that benefit from smarter models rather than working around their limitations.

### Context Engineering
What configuration of context is most likely to generate the model's desired behavior? This has replaced prompt engineering as the primary skill.

## Project Structure

```
.
├── src/
│   ├── index.tsx              # Main entry, lesson router
│   ├── components/            # UI components
│   ├── lessons/               # Lesson content
│   └── utils/                 # Theme, constants
├── examples/                  # Working code samples
├── package.json
└── tsconfig.json
```

## Requirements

- Node.js 20+
- Terminal with ANSI color support
- Minimum 80 column width recommended

## Credits

Based on research and insights from:
- Anthropic Engineering (Claude Code)
- Manus (Peak Ji) - Context engineering
- Cursor - Multi-agent experiments
- Fly.io (Kurt Mackey) - Sprites architecture
- Shrivu Shankar - Agent patterns synthesis
- Davis Treybig - "LLM + Computer" paradigm

## License

MIT
