import React, { useState, useEffect } from 'react';
import { Box, Text, Newline, useInput } from 'ink';
import { theme, icons, progress } from '../utils/theme.js';
import { LessonLayout, ConceptList, ComparisonTable, NavigationHint } from '../components/LessonLayout.js';
import { ProgressBar } from '../components/Box.js';

interface Lesson2Props {
  onNext: () => void;
  onBack: () => void;
}

export function Lesson2ContextEngineering({ onNext, onBack }: Lesson2Props) {
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
      lessonNumber={2}
      title="Context Engineering"
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
      {step === 0 && <Step0Definition />}
      {step === 1 && <Step1ContextDemo />}
      {step === 2 && <Step2Strategies />}
      {step === 3 && <Step3KVCache />}
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

function Step0Definition() {
  return (
    <Box flexDirection="column">
      <Text color={theme.text}>
        {icons.lightning} <Text bold>Context engineering</Text> has replaced prompt
        engineering as the primary skill for building effective agents.
      </Text>
      <Newline />

      <Box borderStyle="round" borderColor={theme.accent} paddingX={2} paddingY={1}>
        <Text color={theme.text} italic>
          "What configuration of context is most likely to generate{'\n'}
          our model's desired behavior?"
        </Text>
        <Text color={theme.textDim}> — Anthropic</Text>
      </Box>
      <Newline />

      <Text color={theme.info}>
        The context window is your most precious resource. How you fill it
        determines everything.
      </Text>
    </Box>
  );
}

function Step1ContextDemo() {
  const [demoMode, setDemoMode] = useState<'naive' | 'smart' | null>(null);
  const [usage, setUsage] = useState(0);
  const [iteration, setIteration] = useState(0);

  useEffect(() => {
    if (demoMode === 'naive') {
      // Simulate naive approach filling context quickly
      const timer = setInterval(() => {
        setUsage(u => {
          if (u >= 100) {
            clearInterval(timer);
            return 100;
          }
          return u + 15;
        });
        setIteration(i => i + 1);
      }, 300);
      return () => clearInterval(timer);
    }
    if (demoMode === 'smart') {
      // Smart approach uses minimal context
      const timer = setInterval(() => {
        setUsage(u => {
          if (u >= 25) {
            clearInterval(timer);
            return 25;
          }
          return u + 3;
        });
        setIteration(i => i + 1);
      }, 300);
      return () => clearInterval(timer);
    }
  }, [demoMode]);

  useInput((input) => {
    if (input === 'a') {
      setDemoMode('naive');
      setUsage(0);
      setIteration(0);
    }
    if (input === 'b') {
      setDemoMode('smart');
      setUsage(0);
      setIteration(0);
    }
    if (input === 'r') {
      setDemoMode(null);
      setUsage(0);
      setIteration(0);
    }
  });

  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>Interactive Demo: Log Analysis</Text>
      <Newline />

      <Text color={theme.textMuted}>
        Task: Analyze a 10MB log file for error patterns.
      </Text>
      <Newline />

      <Box flexDirection="column" gap={1}>
        <Box>
          <Text color={theme.error}>Option A: </Text>
          <Text color={theme.textMuted}>Load entire file into context</Text>
        </Box>
        <Box>
          <Text color={theme.success}>Option B: </Text>
          <Text color={theme.textMuted}>Write a grep script to extract errors</Text>
        </Box>
      </Box>
      <Newline />

      <Box flexDirection="column" marginY={1}>
        <Text color={theme.text}>Context Window Usage:</Text>
        <ProgressBar
          value={usage}
          max={100}
          width={40}
          color={usage > 80 ? theme.error : usage > 50 ? theme.warning : theme.success}
        />
        {iteration > 0 && (
          <Text color={theme.textMuted}>
            Tool calls: {iteration} | Status: {usage >= 100 ? (
              <Text color={theme.error}>OVERFLOW - Agent stuck!</Text>
            ) : demoMode === 'smart' && usage >= 25 ? (
              <Text color={theme.success}>Complete - Found 47 errors</Text>
            ) : (
              'Processing...'
            )}
          </Text>
        )}
      </Box>
      <Newline />

      <Box gap={2}>
        <Text color={theme.secondary}>[a]</Text>
        <Text color={theme.textMuted}>Try naive</Text>
        <Text color={theme.secondary}>[b]</Text>
        <Text color={theme.textMuted}>Try smart</Text>
        <Text color={theme.secondary}>[r]</Text>
        <Text color={theme.textMuted}>Reset</Text>
      </Box>
    </Box>
  );
}

function Step2Strategies() {
  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>Core Strategies</Text>
      <Newline />

      <Box flexDirection="column" gap={1}>
        <Box flexDirection="column">
          <Text color={theme.success} bold>1. Progressive Disclosure</Text>
          <Text color={theme.textMuted}>
            • Start minimal, let the agent accumulate context
          </Text>
          <Text color={theme.textMuted}>
            • Include usage hints in tool outputs (just-in-time)
          </Text>
          <Text color={theme.textMuted}>
            • Use README.md files the agent reads on demand
          </Text>
        </Box>
        <Newline />

        <Box flexDirection="column">
          <Text color={theme.success} bold>2. Context Indirection</Text>
          <Text color={theme.textMuted}>
            • Let agents act on data without seeing all of it
          </Text>
          <Text color={theme.textMuted}>
            • Write grep/awk scripts instead of loading files
          </Text>
          <Text color={theme.textMuted}>
            • Manus achieves 100:1 compression ratios this way
          </Text>
        </Box>
        <Newline />

        <Box flexDirection="column">
          <Text color={theme.success} bold>3. Leverage Model Priors</Text>
          <Text color={theme.textMuted}>
            • Use libraries models already know (pandas, numpy)
          </Text>
          <Text color={theme.textMuted}>
            • Convert legacy formats to JSON/YAML on read
          </Text>
          <Text color={theme.textMuted}>
            • Avoid custom DSLs the model hasn't seen
          </Text>
        </Box>
      </Box>
    </Box>
  );
}

function Step3KVCache() {
  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>The KV-Cache Optimization</Text>
      <Newline />

      <Text color={theme.text}>
        Manus identifies KV-cache hit rate as{' '}
        <Text color={theme.success} bold>the single most important metric</Text>
        {' '}for production agents.
      </Text>
      <Newline />

      <ComparisonTable
        headers={['Token Type', 'Cost (Claude Sonnet)']}
        rows={[
          ['Cached input tokens', '$0.30 / MTok'],
          ['Uncached input tokens', '$3.00 / MTok'],
          ['Savings', '10x difference!'],
        ]}
      />
      <Newline />

      <Text color={theme.info} bold>Rules for High Cache Hit Rates:</Text>
      <Box flexDirection="column" marginLeft={2}>
        <Text color={theme.textMuted}>
          {icons.bullet} Keep prompt prefix stable (1 token change = cache miss)
        </Text>
        <Text color={theme.textMuted}>
          {icons.bullet} Use append-only context when possible
        </Text>
        <Text color={theme.textMuted}>
          {icons.bullet} Consistent tool result serialization
        </Text>
      </Box>
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
          <Text color={theme.success}>{icons.check} Context is finite and precious</Text>
          <Text color={theme.textMuted}>
               Every token has a cost—both financially and cognitively.
          </Text>
        </Box>

        <Box flexDirection="column">
          <Text color={theme.success}>{icons.check} Indirection beats inclusion</Text>
          <Text color={theme.textMuted}>
               Write scripts to process data rather than loading it all.
          </Text>
        </Box>

        <Box flexDirection="column">
          <Text color={theme.success}>{icons.check} Cache hits = cost savings</Text>
          <Text color={theme.textMuted}>
               Stable prefixes can reduce costs by 10x.
          </Text>
        </Box>

        <Box flexDirection="column">
          <Text color={theme.success}>{icons.check} Progressive disclosure scales</Text>
          <Text color={theme.textMuted}>
               Start small, add context only when needed.
          </Text>
        </Box>
      </Box>
      <Newline />

      <Text color={theme.primary} bold>
        {icons.arrow} Next: Multi-Agent Patterns
      </Text>
    </Box>
  );
}
