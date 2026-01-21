import React, { useState } from 'react';
import { Box, Text, Newline, useInput } from 'ink';
import { theme, icons } from '../utils/theme.js';
import { LessonLayout, NavigationHint } from '../components/LessonLayout.js';
import { ProgressBar } from '../components/Box.js';

interface Lesson4Props {
  onNext: () => void;
  onBack: () => void;
}

const CLAUDE_MD_EXAMPLE = `# CLAUDE.md

## Project Overview
This is a Next.js e-commerce application using:
- TypeScript with strict mode
- Prisma for database
- Tailwind CSS for styling

## Commands
- \`npm run dev\` - Start development server
- \`npm run test\` - Run tests
- \`npm run lint\` - Check code style

## Code Style
- Use functional components with hooks
- Prefer named exports over default exports
- Write tests for all new features

## Common Patterns
- Database queries go in \`src/lib/db/\`
- API routes follow REST conventions
- Use Zod for input validation`;

const TOOL_EXAMPLES = {
  bash: `bash: Run any terminal command
  Example: npm install, git status, pytest`,

  read: `read: View file contents
  Example: Read src/index.ts to understand entry point`,

  write: `write: Create or replace entire files
  Example: Write a new component to src/Button.tsx`,

  edit: `edit: Surgical string replacement
  Example: Change "const x = 1" to "const x = 2"`,

  glob: `glob: Find files by pattern
  Example: Find all *.test.ts files`,

  grep: `grep: Search file contents
  Example: Find all uses of "useState"`,
};

export function Lesson4ClaudeCode({ onNext, onBack }: Lesson4Props) {
  const [step, setStep] = useState(0);

  useInput((input, key) => {
    if (key.rightArrow || input === 'n') {
      if (step < 4) {
        setStep(s => s + 1);
      } else {
        onNext();
      }
    }
    if (key.leftArrow || input === 'p') {
      if (step > 0) {
        setStep(s => s - 1);
      } else {
        onBack();
      }
    }
    if (input === 'q') {
      process.exit(0);
    }
  });

  return (
    <LessonLayout
      lessonNumber={4}
      title="Inside Claude Code"
      footer={
        <NavigationHint
          hints={[
            { key: '←/p', action: 'Previous' },
            { key: '→/n', action: 'Next' },
            { key: 'q', action: 'Quit' },
          ]}
        />
      }
    >
      {step === 0 && <Step0Overview />}
      {step === 1 && <Step1CoreTools />}
      {step === 2 && <Step2ClaudeMd />}
      {step === 3 && <Step3BitterLesson />}
      {step === 4 && <Step4Takeaways />}

      <Newline />
      <ProgressBar
        value={step + 1}
        max={5}
        width={30}
        label="Progress"
        color={theme.primary}
      />
    </LessonLayout>
  );
}

function Step0Overview() {
  return (
    <Box flexDirection="column">
      <Text color={theme.text}>
        {icons.code} <Text bold>Claude Code</Text> is Anthropic's official CLI
        for Claude—a reference implementation of the "Agent-with-a-Computer"
        paradigm.
      </Text>
      <Newline />

      <Text color={theme.accent} bold>The Architecture:</Text>
      <Box flexDirection="column" marginLeft={2}>
        <Text color={theme.textMuted}>
          {icons.bullet} Full access to filesystem, terminal, and code execution
        </Text>
        <Text color={theme.textMuted}>
          {icons.bullet} Persistent environment (not ephemeral containers)
        </Text>
        <Text color={theme.textMuted}>
          {icons.bullet} Progressive disclosure via CLAUDE.md files
        </Text>
        <Text color={theme.textMuted}>
          {icons.bullet} Generic tools instead of domain-specific ones
        </Text>
      </Box>
      <Newline />

      <Box borderStyle="round" borderColor={theme.info} paddingX={2}>
        <Text color={theme.info}>
          {icons.lightning} Key insight: The same architecture works for coding
          AND non-coding tasks. Power users manage emails and todo lists with it!
        </Text>
      </Box>
    </Box>
  );
}

function Step1CoreTools() {
  const [selectedTool, setSelectedTool] = useState<string | null>(null);
  const tools = ['bash', 'read', 'write', 'edit', 'glob', 'grep'];

  useInput((input) => {
    const num = parseInt(input);
    if (num >= 1 && num <= 6) {
      setSelectedTool(tools[num - 1]);
    }
  });

  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>Core Tools</Text>
      <Newline />

      <Box flexDirection="column">
        <Text color={theme.text}>
          Claude Code has surprisingly few tools—and that's intentional:
        </Text>
        <Newline />

        <Box flexDirection="column" marginLeft={2}>
          {tools.map((tool, i) => (
            <Box key={tool}>
              <Text color={theme.secondary}>[{i + 1}]</Text>
              <Text color={selectedTool === tool ? theme.success : theme.textMuted}>
                {' '}{tool.padEnd(8)}
              </Text>
              {selectedTool === tool && (
                <Text color={theme.text}> {icons.arrow} Selected</Text>
              )}
            </Box>
          ))}
        </Box>
      </Box>
      <Newline />

      {selectedTool && (
        <Box borderStyle="round" borderColor={theme.success} paddingX={2}>
          <Text color={theme.text}>
            {TOOL_EXAMPLES[selectedTool as keyof typeof TOOL_EXAMPLES]}
          </Text>
        </Box>
      )}

      {!selectedTool && (
        <Text color={theme.textDim}>Press 1-6 to explore each tool</Text>
      )}
    </Box>
  );
}

function Step2ClaudeMd() {
  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>The CLAUDE.md File</Text>
      <Newline />

      <Text color={theme.text}>
        CLAUDE.md is project-specific context that Claude reads automatically.
        It's the primary mechanism for progressive disclosure.
      </Text>
      <Newline />

      <Box
        borderStyle="round"
        borderColor={theme.textDim}
        paddingX={1}
        flexDirection="column"
      >
        <Text color={theme.secondary}>{CLAUDE_MD_EXAMPLE}</Text>
      </Box>
      <Newline />

      <Text color={theme.info}>
        {icons.star} Tip: Put CLAUDE.md files in subdirectories for
        module-specific instructions.
      </Text>
    </Box>
  );
}

function Step3BitterLesson() {
  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>The Bitter Lesson Applied</Text>
      <Newline />

      <Box borderStyle="round" borderColor={theme.warning} paddingX={2} paddingY={1}>
        <Text color={theme.text} italic>
          "If model progress is the rising tide, we want to be the boat,{'\n'}
          not the pillar stuck to the seabed."
        </Text>
        <Text color={theme.textDim}> — Manus Team</Text>
      </Box>
      <Newline />

      <Text color={theme.text}>
        Boris Cherny (Claude Code creator) cited the Bitter Lesson as influencing
        the decision to keep Claude Code "unopinionated."
      </Text>
      <Newline />

      <Box flexDirection="column" marginLeft={2}>
        <Text color={theme.success}>
          {icons.check} Generic tools over domain-specific ones
        </Text>
        <Text color={theme.success}>
          {icons.check} Let the model figure out how to use them
        </Text>
        <Text color={theme.success}>
          {icons.check} Remove complexity, don't add it
        </Text>
        <Text color={theme.success}>
          {icons.check} Adapt to model improvements automatically
        </Text>
      </Box>
      <Newline />

      <Text color={theme.textMuted}>
        Manus rebuilt their agent framework <Text bold>5 times</Text> in 6 months.
        Each performance gain came from removing complexity, not adding it.
      </Text>
    </Box>
  );
}

function Step4Takeaways() {
  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>{icons.star} Key Takeaways</Text>
      <Newline />

      <Box flexDirection="column" marginLeft={2} gap={1}>
        <Box flexDirection="column">
          <Text color={theme.success}>{icons.check} Fewer tools is often better</Text>
          <Text color={theme.textMuted}>
               Generic capabilities beat specialized ones.
          </Text>
        </Box>

        <Box flexDirection="column">
          <Text color={theme.success}>{icons.check} CLAUDE.md enables progressive disclosure</Text>
          <Text color={theme.textMuted}>
               Project context on demand, not upfront.
          </Text>
        </Box>

        <Box flexDirection="column">
          <Text color={theme.success}>{icons.check} Bet on model improvements</Text>
          <Text color={theme.textMuted}>
               Build harnesses that benefit from smarter models.
          </Text>
        </Box>

        <Box flexDirection="column">
          <Text color={theme.success}>{icons.check} The computer IS the tool</Text>
          <Text color={theme.textMuted}>
               File system + bash + code execution = universal capability.
          </Text>
        </Box>
      </Box>
      <Newline />

      <Text color={theme.primary} bold>
        {icons.arrow} Next: Build Your Own Agent
      </Text>
    </Box>
  );
}
