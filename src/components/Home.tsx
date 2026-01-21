import React from 'react';
import { Box, Text, Newline, useInput } from 'ink';
import { theme, icons } from '../utils/theme.js';

interface HomeProps {
  onSelectLesson: (lesson: number) => void;
}

const ASCII_BANNER = `
   _                    _      _             _     _ _            _
  /_\\  __ _ ___ _ _  | |_   /_\\  _ _ __| |_ (_) |_ ___ __| |_ _  _ _ _ ___
 / _ \\/ _\` / -_) ' \\ |  _| / _ \\| '_/ _| ' \\| |  _/ -_) _|  _| || | '_/ -_)
/_/ \\_\\__, \\___|_||_| \\__| /_/ \\_\\_| \\__|_||_|_|\\__\\___\\__|\\__|\\___/|_| \\___|
      |___/
`;

const LESSONS = [
  { num: 1, title: 'The Agent Loop', desc: 'Unix primitives and the core loop' },
  { num: 2, title: 'Context Engineering', desc: 'The new critical skill' },
  { num: 3, title: 'Multi-Agent Patterns', desc: 'Plan/Execute/Task architecture' },
  { num: 4, title: 'Inside Claude Code', desc: 'Tools, CLAUDE.md, and design' },
  { num: 5, title: 'Build Your Own Agent', desc: 'Three tracks to mastery' },
];

export function Home({ onSelectLesson }: HomeProps) {
  useInput((input, key) => {
    const num = parseInt(input);
    if (num >= 1 && num <= 5) {
      onSelectLesson(num);
    }
    if (key.return) {
      onSelectLesson(1);
    }
    if (input === 'q') {
      process.exit(0);
    }
  });

  return (
    <Box flexDirection="column" paddingX={2}>
      {/* Banner */}
      <Text color={theme.primary}>{ASCII_BANNER}</Text>

      {/* Subtitle */}
      <Box justifyContent="center">
        <Text color={theme.accent} bold>
          Interactive Terminal Tutorial • January 2026
        </Text>
      </Box>
      <Newline />

      {/* Description */}
      <Box marginBottom={1}>
        <Text color={theme.text}>
          Learn modern AI agent architecture through hands-on examples.
          Based on research from Anthropic, Manus, Cursor, and Fly.io.
        </Text>
      </Box>
      <Newline />

      {/* Lesson List */}
      <Text color={theme.textMuted}>{'─'.repeat(60)}</Text>
      <Newline />

      <Text color={theme.secondary} bold>LESSONS</Text>
      <Newline />

      {LESSONS.map((lesson) => (
        <Box key={lesson.num} marginLeft={2}>
          <Text color={theme.accent}>[{lesson.num}]</Text>
          <Text color={theme.text}> {lesson.title.padEnd(25)}</Text>
          <Text color={theme.textMuted}>{lesson.desc}</Text>
        </Box>
      ))}
      <Newline />

      <Text color={theme.textMuted}>{'─'.repeat(60)}</Text>
      <Newline />

      {/* Key Concepts Preview */}
      <Text color={theme.secondary} bold>KEY CONCEPTS YOU'LL LEARN</Text>
      <Newline />

      <Box marginLeft={2} flexDirection="column">
        <Text color={theme.textMuted}>
          {icons.bullet} The "Agent-with-a-Computer" paradigm
        </Text>
        <Text color={theme.textMuted}>
          {icons.bullet} Context engineering vs prompt engineering
        </Text>
        <Text color={theme.textMuted}>
          {icons.bullet} KV-cache optimization for 10x cost savings
        </Text>
        <Text color={theme.textMuted}>
          {icons.bullet} Plan/Execution/Task multi-agent pattern
        </Text>
        <Text color={theme.textMuted}>
          {icons.bullet} The Bitter Lesson applied to agents
        </Text>
      </Box>
      <Newline />

      <Text color={theme.textMuted}>{'─'.repeat(60)}</Text>
      <Newline />

      {/* Navigation */}
      <Box gap={3}>
        <Box>
          <Text color={theme.success}>[Enter]</Text>
          <Text color={theme.textMuted}> Start from Lesson 1</Text>
        </Box>
        <Box>
          <Text color={theme.info}>[1-5]</Text>
          <Text color={theme.textMuted}> Jump to lesson</Text>
        </Box>
        <Box>
          <Text color={theme.error}>[q]</Text>
          <Text color={theme.textMuted}> Quit</Text>
        </Box>
      </Box>
    </Box>
  );
}
