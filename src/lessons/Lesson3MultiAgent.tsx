import React, { useState, useEffect } from 'react';
import { Box, Text, Newline, useInput } from 'ink';
import { theme, icons } from '../utils/theme.js';
import { LessonLayout, ComparisonTable, NavigationHint } from '../components/LessonLayout.js';
import { ProgressBar } from '../components/Box.js';

interface Lesson3Props {
  onNext: () => void;
  onBack: () => void;
}

export function Lesson3MultiAgent({ onNext, onBack }: Lesson3Props) {
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
      lessonNumber={3}
      title="Multi-Agent Patterns"
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
      {step === 0 && <Step0WhenMultiAgent />}
      {step === 1 && <Step1PlanExecuteTask />}
      {step === 2 && <Step2Demo />}
      {step === 3 && <Step3CursorFindings />}
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

function Step0WhenMultiAgent() {
  return (
    <Box flexDirection="column">
      <Text color={theme.text}>
        {icons.robot} Not every problem needs multiple agents. Understanding
        when to use them is crucial.
      </Text>
      <Newline />

      <ComparisonTable
        headers={['Single Agent', 'Multi-Agent']}
        rows={[
          ['Sequential tasks', 'Parallelizable work'],
          ['Small context needs', 'Large/varied contexts'],
          ['Simple workflows', 'Complex coordination'],
          ['Quick iterations', 'Long-running tasks'],
        ]}
      />
      <Newline />

      <Box borderStyle="round" borderColor={theme.warning} paddingX={2}>
        <Text color={theme.warning}>
          {icons.warning} Warning: Multi-agent adds complexity. Start simple,
          add agents only when single-agent fails.
        </Text>
      </Box>
    </Box>
  );
}

function Step1PlanExecuteTask() {
  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>The Plan/Execution/Task Pattern</Text>
      <Newline />

      <Text color={theme.textMuted}>
        Modern agents converge on three roles:
      </Text>
      <Newline />

      <Box flexDirection="column" marginLeft={2} gap={1}>
        <Box flexDirection="column">
          <Text color={theme.info} bold>
            {icons.star} Plan Agent
          </Text>
          <Text color={theme.textMuted}>
            Discovery, mapping, generating pointers
          </Text>
          <Text color={theme.textDim}>
            Scope: Broad context, strategic decisions
          </Text>
        </Box>

        <Box flexDirection="column">
          <Text color={theme.success} bold>
            {icons.code} Execution Agent
          </Text>
          <Text color={theme.textMuted}>
            Builds things given a plan, writes scripts, verifies
          </Text>
          <Text color={theme.textDim}>
            Scope: Full task, hands-on implementation
          </Text>
        </Box>

        <Box flexDirection="column">
          <Text color={theme.secondary} bold>
            {icons.lightning} Task Agent
          </Text>
          <Text color={theme.textMuted}>
            Transient sub-agent for parallel/isolated work
          </Text>
          <Text color={theme.textDim}>
            Scope: Single chunk of work, ephemeral
          </Text>
        </Box>
      </Box>
      <Newline />

      <Text color={theme.textMuted} italic>
        This replaces the 2024 pattern of hand-crafted "SQL Specialist"
        or "Researcher" subagents.
      </Text>
    </Box>
  );
}

function Step2Demo() {
  const [mode, setMode] = useState<'single' | 'multi' | null>(null);
  const [singleProgress, setSingleProgress] = useState(0);
  const [taskProgress, setTaskProgress] = useState<number[]>([0, 0, 0, 0, 0]);

  useEffect(() => {
    if (mode === 'single') {
      const timer = setInterval(() => {
        setSingleProgress(p => {
          if (p >= 100) {
            clearInterval(timer);
            return 100;
          }
          return p + 2;
        });
      }, 100);
      return () => clearInterval(timer);
    }
    if (mode === 'multi') {
      const timers = taskProgress.map((_, i) => {
        return setInterval(() => {
          setTaskProgress(prev => {
            const next = [...prev];
            if (next[i] < 100) {
              next[i] = Math.min(100, next[i] + 8 + Math.random() * 5);
            }
            return next;
          });
        }, 100 + i * 20);
      });
      return () => timers.forEach(t => clearInterval(t));
    }
  }, [mode]);

  useInput((input) => {
    if (input === 's') {
      setMode('single');
      setSingleProgress(0);
      setTaskProgress([0, 0, 0, 0, 0]);
    }
    if (input === 'm') {
      setMode('multi');
      setSingleProgress(0);
      setTaskProgress([0, 0, 0, 0, 0]);
    }
    if (input === 'r') {
      setMode(null);
      setSingleProgress(0);
      setTaskProgress([0, 0, 0, 0, 0]);
    }
  });

  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>Interactive Demo: Process 100 Records</Text>
      <Newline />

      <Box flexDirection="column" gap={1}>
        <Text color={theme.text}>Single Agent (Sequential):</Text>
        <ProgressBar
          value={singleProgress}
          max={100}
          width={40}
          color={theme.warning}
        />
        {singleProgress >= 100 && (
          <Text color={theme.textMuted}>Completed in ~5 seconds</Text>
        )}
      </Box>
      <Newline />

      <Box flexDirection="column" gap={1}>
        <Text color={theme.text}>Plan Agent + 5 Task Agents (Parallel):</Text>
        {taskProgress.map((p, i) => (
          <Box key={i}>
            <Text color={theme.textMuted}>Task {i + 1}: </Text>
            <ProgressBar
              value={Math.round(p)}
              max={100}
              width={30}
              showPercentage={false}
              color={p >= 100 ? theme.success : theme.info}
            />
            {p >= 100 && <Text color={theme.success}> {icons.check}</Text>}
          </Box>
        ))}
        {taskProgress.every(p => p >= 100) && (
          <Text color={theme.success}>Completed in ~1 second (5x faster!)</Text>
        )}
      </Box>
      <Newline />

      <Box gap={2}>
        <Text color={theme.secondary}>[s]</Text>
        <Text color={theme.textMuted}>Single agent</Text>
        <Text color={theme.secondary}>[m]</Text>
        <Text color={theme.textMuted}>Multi-agent</Text>
        <Text color={theme.secondary}>[r]</Text>
        <Text color={theme.textMuted}>Reset</Text>
      </Box>
    </Box>
  );
}

function Step3CursorFindings() {
  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>Cursor's Multi-Agent Research</Text>
      <Newline />

      <Text color={theme.textMuted}>
        Cursor ran experiments with hundreds of concurrent agents working for weeks:
      </Text>
      <Newline />

      <Box flexDirection="column" marginLeft={2} gap={1}>
        <Text color={theme.info}>
          {icons.code} Built a web browser from scratch: 1M+ lines, 1000 files
        </Text>

        <Box flexDirection="column">
          <Text color={theme.error}>
            {icons.cross} Dynamic coordination (self-coordinating) FAILED
          </Text>
          <Box marginLeft={2}>
            <Text color={theme.textDim}>
              Lock contention, race conditions, chaos
            </Text>
          </Box>
        </Box>

        <Box flexDirection="column">
          <Text color={theme.success}>
            {icons.check} Static planning with central planner SUCCEEDED
          </Text>
          <Box marginLeft={2}>
            <Text color={theme.textDim}>
              Single source of truth for task assignment
            </Text>
          </Box>
        </Box>

        <Text color={theme.warning}>
          {icons.star} Used "judge agent" at cycle end to decide continuation
        </Text>

        <Text color={theme.info}>
          {icons.lightning} Fresh context periodically to combat drift
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
          <Text color={theme.success}>{icons.check} Central planning beats dynamic coordination</Text>
          <Text color={theme.textMuted}>
               A single planner prevents chaos in multi-agent systems.
          </Text>
        </Box>

        <Box flexDirection="column">
          <Text color={theme.success}>{icons.check} Task agents should be ephemeral</Text>
          <Text color={theme.textMuted}>
               Spawn, execute, return results, terminate.
          </Text>
        </Box>

        <Box flexDirection="column">
          <Text color={theme.success}>{icons.check} Fresh context prevents drift</Text>
          <Text color={theme.textMuted}>
               Long-running agents accumulate errors; reset periodically.
          </Text>
        </Box>

        <Box flexDirection="column">
          <Text color={theme.success}>{icons.check} Judge agents validate completeness</Text>
          <Text color={theme.textMuted}>
               Separate verification from execution.
          </Text>
        </Box>
      </Box>
      <Newline />

      <Text color={theme.primary} bold>
        {icons.arrow} Next: Inside Claude Code
      </Text>
    </Box>
  );
}
