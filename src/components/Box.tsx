import React from 'react';
import { Box as InkBox, Text } from 'ink';
import { theme, box } from '../utils/theme.js';

interface FramedBoxProps {
  title?: string;
  children: React.ReactNode;
  width?: number;
  borderColor?: string;
}

export function FramedBox({
  title,
  children,
  width = 60,
  borderColor = theme.primary
}: FramedBoxProps) {
  const innerWidth = width - 2;

  const topBorder = title
    ? `${box.topLeft}${box.horizontal} ${title} ${box.horizontal.repeat(Math.max(0, innerWidth - title.length - 3))}${box.topRight}`
    : `${box.topLeft}${box.horizontal.repeat(innerWidth)}${box.topRight}`;

  const bottomBorder = `${box.bottomLeft}${box.horizontal.repeat(innerWidth)}${box.bottomRight}`;

  return (
    <InkBox flexDirection="column">
      <Text color={borderColor}>{topBorder}</Text>
      <InkBox flexDirection="column" paddingX={1}>
        {children}
      </InkBox>
      <Text color={borderColor}>{bottomBorder}</Text>
    </InkBox>
  );
}

interface ProgressBarProps {
  value: number;
  max?: number;
  width?: number;
  label?: string;
  showPercentage?: boolean;
  color?: string;
}

export function ProgressBar({
  value,
  max = 100,
  width = 40,
  label,
  showPercentage = true,
  color = theme.success
}: ProgressBarProps) {
  const percentage = Math.min(100, Math.max(0, (value / max) * 100));
  const filledWidth = Math.round((percentage / 100) * width);
  const emptyWidth = width - filledWidth;

  const filled = '█'.repeat(filledWidth);
  const empty = '░'.repeat(emptyWidth);

  return (
    <InkBox>
      {label && <Text color={theme.textMuted}>{label}: </Text>}
      <Text color={color}>[{filled}</Text>
      <Text color={theme.textDim}>{empty}]</Text>
      {showPercentage && <Text color={theme.text}> {Math.round(percentage)}%</Text>}
    </InkBox>
  );
}

interface CodeBlockProps {
  children: string;
  language?: string;
}

export function CodeBlock({ children, language }: CodeBlockProps) {
  return (
    <InkBox
      flexDirection="column"
      marginY={1}
      paddingX={2}
      borderStyle="single"
      borderColor={theme.textDim}
    >
      {language && (
        <Text color={theme.textMuted} dimColor>
          {language}
        </Text>
      )}
      <Text color={theme.secondary}>{children}</Text>
    </InkBox>
  );
}

interface HighlightProps {
  children: React.ReactNode;
  type?: 'primary' | 'success' | 'warning' | 'error' | 'info';
}

export function Highlight({ children, type = 'primary' }: HighlightProps) {
  const colorMap = {
    primary: theme.primary,
    success: theme.success,
    warning: theme.warning,
    error: theme.error,
    info: theme.info,
  };

  return <Text color={colorMap[type]} bold>{children}</Text>;
}
