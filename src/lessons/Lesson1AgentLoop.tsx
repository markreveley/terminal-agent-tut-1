import React, { useState } from 'react';
import { Box, Text, Newline, useInput } from 'ink';
import { theme, icons } from '../utils/theme.js';
import { LessonLayout, ConceptList, NavigationHint } from '../components/LessonLayout.js';
import { CodeBlock, ProgressBar } from '../components/Box.js';

interface Lesson1Props {
  onNext: () => void;
  onBack: () => void;
}

const AGENT_LOOP_CODE = `while true; do
  # 1. Build context from prompt + history
  CONTEXT=$(cat prompt.txt history.txt)

  # 2. Send to LLM, get response
  RESPONSE=$(echo "$CONTEXT" | llm)

  # 3. Check if response contains a tool call
  if has_tool_call "$RESPONSE"; then
    # 4. Execute the tool, append result to history
    RESULT=$(execute_tool "$RESPONSE")
    echo "$RESULT" >> history.txt
  else
    # 5. No tool call = final answer
    echo "$RESPONSE"
    break
  fi
done`;

const MINIMAL_AGENT = `#!/bin/bash
# The simplest possible agent

SYSTEM_PROMPT="You are a helpful assistant."

agent() {
  local user_input="$1"

  # Build the request
  curl -s https://api.anthropic.com/v1/messages \\
    -H "x-api-key: $ANTHROPIC_API_KEY" \\
    -H "content-type: application/json" \\
    -H "anthropic-version: 2023-06-01" \\
    -d '{
      "model": "claude-sonnet-4-20250514",
      "max_tokens": 1024,
      "system": "'"$SYSTEM_PROMPT"'",
      "messages": [
        {"role": "user", "content": "'"$user_input"'"}
      ]
    }' | jq -r '.content[0].text'
}

# Usage: agent "What is 2+2?"`;

export function Lesson1AgentLoop({ onNext, onBack }: Lesson1Props) {
  const [step, setStep] = useState(0);

  useInput((input, key) => {
    if (key.rightArrow || input === 'n') {
      if (step < 3) {
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
      lessonNumber={1}
      title="The Agent Loop"
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
      {step === 0 && <Step0Introduction />}
      {step === 1 && <Step1CoreLoop />}
      {step === 2 && <Step2MinimalAgent />}
      {step === 3 && <Step3KeyTakeaways />}

      <Newline />
      <ProgressBar
        value={step + 1}
        max={4}
        width={30}
        label="Progress"
        color={theme.primary}
      />
    </LessonLayout>
  );
}

function Step0Introduction() {
  return (
    <Box flexDirection="column">
      <Text color={theme.text}>
        {icons.robot} Every AI agent—from simple chatbots to complex autonomous
        systems—follows the same fundamental pattern.
      </Text>
      <Newline />

      <Text color={theme.accent} bold>The Big Insight:</Text>
      <Newline />

      <Box marginLeft={2} flexDirection="column">
        <Text color={theme.text}>
          An agent is just a <Text color={theme.success} bold>loop</Text> that:
        </Text>
        <Text color={theme.textMuted}>  1. Gathers context</Text>
        <Text color={theme.textMuted}>  2. Calls an LLM</Text>
        <Text color={theme.textMuted}>  3. Executes any tool calls</Text>
        <Text color={theme.textMuted}>  4. Repeats until done</Text>
      </Box>
      <Newline />

      <Text color={theme.info}>
        That's it. Everything else is optimization and specialization.
      </Text>
    </Box>
  );
}

function Step1CoreLoop() {
  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>The Core Loop (in Bash)</Text>
      <Newline />

      <Text color={theme.textMuted}>
        Here's the agentic loop expressed as a shell script:
      </Text>
      <Newline />

      <Box borderStyle="round" borderColor={theme.textDim} paddingX={1}>
        <Text color={theme.secondary}>{AGENT_LOOP_CODE}</Text>
      </Box>
      <Newline />

      <ConceptList
        title="Key Components:"
        concepts={[
          'Context = System prompt + Conversation history',
          'Tool calls are detected in the response',
          'History accumulates across iterations',
          'Loop exits when LLM gives a final answer',
        ]}
      />
    </Box>
  );
}

function Step2MinimalAgent() {
  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>A Real Minimal Agent</Text>
      <Newline />

      <Text color={theme.textMuted}>
        Here's a working agent using just curl and jq:
      </Text>
      <Newline />

      <Box borderStyle="round" borderColor={theme.textDim} paddingX={1}>
        <Text color={theme.secondary}>{MINIMAL_AGENT}</Text>
      </Box>
      <Newline />

      <Text color={theme.info}>
        {icons.lightning} This is a single-turn agent. Multi-turn agents
        maintain history across calls.
      </Text>
    </Box>
  );
}

function Step3KeyTakeaways() {
  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>{icons.star} Key Takeaways</Text>
      <Newline />

      <Box flexDirection="column" marginLeft={2}>
        <Text color={theme.success}>
          {icons.check} Agents are loops, not magic
        </Text>
        <Text color={theme.textMuted}>
             The complexity comes from tool definitions, not the loop itself.
        </Text>
        <Newline />

        <Text color={theme.success}>
          {icons.check} Context is everything
        </Text>
        <Text color={theme.textMuted}>
             What you put in the context window determines behavior.
        </Text>
        <Newline />

        <Text color={theme.success}>
          {icons.check} Tool calls extend capabilities
        </Text>
        <Text color={theme.textMuted}>
             The LLM decides when to use tools; you define what's available.
        </Text>
        <Newline />

        <Text color={theme.success}>
          {icons.check} History enables multi-turn reasoning
        </Text>
        <Text color={theme.textMuted}>
             Appending results lets the agent build on previous actions.
        </Text>
      </Box>
      <Newline />

      <Text color={theme.primary} bold>
        {icons.arrow} Next: Context Engineering—the new critical skill
      </Text>
    </Box>
  );
}
