import React from 'react';
import { Box, Text, Newline } from 'ink';
import { theme, icons } from '../utils/theme.js';

interface LessonLayoutProps {
  lessonNumber: number;
  title: string;
  children: React.ReactNode;
  footer?: React.ReactNode;
}

export function LessonLayout({
  lessonNumber,
  title,
  children,
  footer
}: LessonLayoutProps) {
  return (
    <Box flexDirection="column" paddingX={2} paddingY={1}>
      {/* Header */}
      <Box marginBottom={1}>
        <Text color={theme.accent} bold>
          LESSON {lessonNumber}:
        </Text>
        <Text color={theme.text} bold>
          {' '}{title.toUpperCase()}
        </Text>
      </Box>

      {/* Separator */}
      <Text color={theme.textDim}>{'─'.repeat(60)}</Text>
      <Newline />

      {/* Content */}
      <Box flexDirection="column" marginBottom={1}>
        {children}
      </Box>

      {/* Footer */}
      {footer && (
        <>
          <Newline />
          <Text color={theme.textDim}>{'─'.repeat(60)}</Text>
          <Newline />
          {footer}
        </>
      )}
    </Box>
  );
}

interface ConceptListProps {
  title: string;
  concepts: string[];
}

export function ConceptList({ title, concepts }: ConceptListProps) {
  return (
    <Box flexDirection="column" marginY={1}>
      <Text color={theme.info} bold>{title}</Text>
      {concepts.map((concept, i) => (
        <Text key={i} color={theme.textMuted}>
          {icons.bullet} {concept}
        </Text>
      ))}
    </Box>
  );
}

interface ComparisonTableProps {
  headers: [string, string];
  rows: Array<[string, string]>;
}

export function ComparisonTable({ headers, rows }: ComparisonTableProps) {
  const col1Width = 28;
  const col2Width = 28;

  return (
    <Box flexDirection="column" marginY={1}>
      {/* Headers */}
      <Box>
        <Text color={theme.accent} bold>
          {headers[0].padEnd(col1Width)}
        </Text>
        <Text color={theme.success} bold>
          {headers[1].padEnd(col2Width)}
        </Text>
      </Box>
      <Text color={theme.textDim}>{'─'.repeat(col1Width + col2Width)}</Text>

      {/* Rows */}
      {rows.map(([col1, col2], i) => (
        <Box key={i}>
          <Text color={theme.textMuted}>{col1.padEnd(col1Width)}</Text>
          <Text color={theme.text}>{col2.padEnd(col2Width)}</Text>
        </Box>
      ))}
    </Box>
  );
}

interface NavigationHintProps {
  hints: Array<{ key: string; action: string }>;
}

export function NavigationHint({ hints }: NavigationHintProps) {
  return (
    <Box gap={2}>
      {hints.map(({ key, action }, i) => (
        <Box key={i}>
          <Text color={theme.secondary}>[{key}]</Text>
          <Text color={theme.textMuted}> {action}</Text>
        </Box>
      ))}
    </Box>
  );
}
