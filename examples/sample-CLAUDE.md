# CLAUDE.md - Sample Project Configuration

This is an example CLAUDE.md file that demonstrates how to provide
context to Claude Code for a project.

## Project Overview

This is a Node.js/TypeScript project that implements an interactive
terminal tutorial about AI agent architecture.

**Tech Stack:**
- TypeScript with strict mode
- Ink (React for CLIs) for terminal UI
- Node.js 20+

## Commands

```bash
# Install dependencies
npm install

# Run in development mode (with hot reload)
npm run dev

# Build for production
npm run build

# Run the built version
npm start

# Type check without building
npm run typecheck
```

## Project Structure

```
.
├── src/
│   ├── index.tsx          # Main entry point
│   ├── components/        # Reusable UI components
│   │   ├── Box.tsx        # Framed boxes, progress bars
│   │   ├── Home.tsx       # Home screen
│   │   └── LessonLayout.tsx # Lesson template
│   ├── lessons/           # Individual lesson components
│   │   ├── Lesson1AgentLoop.tsx
│   │   ├── Lesson2ContextEngineering.tsx
│   │   ├── Lesson3MultiAgent.tsx
│   │   ├── Lesson4ClaudeCode.tsx
│   │   └── Lesson5BuildAgent.tsx
│   └── utils/
│       └── theme.ts       # Colors and visual constants
├── examples/              # Working code examples
│   ├── unix-agent.sh      # Bash agent implementation
│   ├── sdk-agent.ts       # TypeScript SDK implementation
│   └── beam-agent.ex      # Elixir/OTP implementation
└── package.json
```

## Code Style

- Use functional React components with hooks
- Prefer named exports over default exports
- Keep components focused and single-purpose
- Use the theme constants for colors (never hardcode)
- Handle keyboard input with Ink's `useInput` hook

## Common Patterns

### Adding a New Lesson

1. Create `src/lessons/LessonXName.tsx`
2. Follow the existing lesson structure with steps
3. Add the lesson to the router in `src/index.tsx`
4. Update the LESSONS array in `src/components/Home.tsx`

### Keyboard Navigation

All lessons use this pattern:
```tsx
useInput((input, key) => {
  if (key.rightArrow || input === 'n') nextStep();
  if (key.leftArrow || input === 'p') prevStep();
  if (input === 'q') process.exit(0);
});
```

### Interactive Demos

For animated demos, use `useEffect` with intervals:
```tsx
useEffect(() => {
  if (demoActive) {
    const timer = setInterval(() => {
      setProgress(p => p + 1);
    }, 100);
    return () => clearInterval(timer);
  }
}, [demoActive]);
```

## Testing

Currently no automated tests. Manual testing:
1. Run `npm run dev`
2. Navigate through all lessons
3. Test all interactive demos
4. Verify keyboard navigation works

## Known Issues

- Terminal must be at least 80 columns wide
- Some emojis may not render in all terminals
- Windows terminal support is limited
