import React, { useState } from 'react';
import { Box, Text, Newline, useInput } from 'ink';
import { theme, icons } from '../utils/theme.js';
import { LessonLayout, NavigationHint } from '../components/LessonLayout.js';
import { ProgressBar } from '../components/Box.js';

interface Lesson5Props {
  onComplete: () => void;
  onBack: () => void;
}

const UNIX_AGENT_CODE = `#!/bin/bash
# Minimal agent using bash, curl, and jq

ANTHROPIC_API_KEY="\${ANTHROPIC_API_KEY:?Set ANTHROPIC_API_KEY}"

call_claude() {
  local messages="$1"
  curl -s https://api.anthropic.com/v1/messages \\
    -H "x-api-key: $ANTHROPIC_API_KEY" \\
    -H "content-type: application/json" \\
    -H "anthropic-version: 2023-06-01" \\
    -d "{
      \\"model\\": \\"claude-sonnet-4-20250514\\",
      \\"max_tokens\\": 1024,
      \\"messages\\": $messages
    }" | jq -r '.content[0].text'
}

# Example usage
response=$(call_claude '[{"role":"user","content":"Hello!"}]')
echo "$response"`;

const SDK_AGENT_CODE = `import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

// Define tools the agent can use
const tools = [
  {
    name: "read_file",
    description: "Read contents of a file",
    input_schema: {
      type: "object",
      properties: {
        path: { type: "string", description: "File path" }
      },
      required: ["path"]
    }
  }
];

async function agent(task: string) {
  const messages = [{ role: "user", content: task }];

  while (true) {
    const response = await client.messages.create({
      model: "claude-sonnet-4-20250514",
      max_tokens: 1024,
      tools,
      messages
    });

    // Check for tool use
    const toolUse = response.content.find(b => b.type === "tool_use");
    if (!toolUse) {
      // Final response
      return response.content[0].text;
    }

    // Execute tool and continue loop
    const result = await executeTool(toolUse);
    messages.push({ role: "assistant", content: response.content });
    messages.push({ role: "user", content: [
      { type: "tool_result", tool_use_id: toolUse.id, content: result }
    ]});
  }
}`;

const BEAM_AGENT_CODE = `defmodule MyAgent do
  use Jido.Agent,
    name: "my_agent",
    description: "A task-executing agent"

  def execute(task) do
    # Plan Agent determines subtasks
    {:ok, plan} = plan_task(task)

    # Spawn Task Agents in parallel
    plan.subtasks
    |> Task.async_stream(&execute_subtask/1,
         max_concurrency: 10,
         on_timeout: :kill_task)
    |> Enum.map(fn {:ok, result} -> result end)
    |> synthesize_results()
  end

  defp execute_subtask(subtask) do
    # Each task agent has isolated context
    {:ok, pid} = TaskAgent.start_link(subtask)
    TaskAgent.run(pid)
  end
end

# OTP supervision for fault tolerance
children = [
  {Task.Supervisor, name: TaskSupervisor},
  {MyAgent, []}
]
Supervisor.start_link(children, strategy: :one_for_one)`;

export function Lesson5BuildAgent({ onComplete, onBack }: Lesson5Props) {
  const [step, setStep] = useState(0);
  const [selectedTrack, setSelectedTrack] = useState<'unix' | 'sdk' | 'beam' | null>(null);

  useInput((input, key) => {
    if (key.rightArrow || input === 'n') {
      if (step < 3) {
        setStep(s => s + 1);
      } else {
        onComplete();
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
    if (step === 0) {
      if (input === '1') setSelectedTrack('unix');
      if (input === '2') setSelectedTrack('sdk');
      if (input === '3') setSelectedTrack('beam');
    }
  });

  return (
    <LessonLayout
      lessonNumber={5}
      title="Build Your Own Agent"
      footer={
        <NavigationHint
          hints={[
            { key: '←/p', action: 'Previous' },
            { key: '→/n', action: step === 3 ? 'Finish' : 'Next' },
            { key: 'q', action: 'Quit' },
          ]}
        />
      }
    >
      {step === 0 && <Step0ChooseTrack selectedTrack={selectedTrack} />}
      {step === 1 && <Step1ShowCode track={selectedTrack} />}
      {step === 2 && <Step2NextSteps track={selectedTrack} />}
      {step === 3 && <Step3Summary />}

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

function Step0ChooseTrack({ selectedTrack }: { selectedTrack: 'unix' | 'sdk' | 'beam' | null }) {
  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>Choose Your Path</Text>
      <Newline />

      <Text color={theme.text}>
        Three approaches to building agents, from simple to advanced:
      </Text>
      <Newline />

      <Box flexDirection="column" marginLeft={2} gap={1}>
        <Box flexDirection="column">
          <Box>
            <Text color={theme.secondary}>[1]</Text>
            <Text color={selectedTrack === 'unix' ? theme.success : theme.text}>
              {' '}{icons.shell} Unix Track
            </Text>
          </Box>
          <Box marginLeft={4}>
            <Text color={theme.textMuted}>
              Build an agent using only bash, jq, and curl.
            </Text>
          </Box>
          <Box marginLeft={4}>
            <Text color={theme.textDim}>
              Best for: Learning fundamentals, quick prototypes
            </Text>
          </Box>
        </Box>

        <Box flexDirection="column">
          <Box>
            <Text color={theme.secondary}>[2]</Text>
            <Text color={selectedTrack === 'sdk' ? theme.success : theme.text}>
              {' '}{icons.robot} Anthropic SDK Track
            </Text>
          </Box>
          <Box marginLeft={4}>
            <Text color={theme.textMuted}>
              Use the official SDK with proper tool definitions.
            </Text>
          </Box>
          <Box marginLeft={4}>
            <Text color={theme.textDim}>
              Best for: Production agents, full feature access
            </Text>
          </Box>
        </Box>

        <Box flexDirection="column">
          <Box>
            <Text color={theme.secondary}>[3]</Text>
            <Text color={selectedTrack === 'beam' ? theme.success : theme.text}>
              {' '}{icons.beam} BEAM Track (Advanced)
            </Text>
          </Box>
          <Box marginLeft={4}>
            <Text color={theme.textMuted}>
              Orchestrate agents with Elixir/OTP supervision.
            </Text>
          </Box>
          <Box marginLeft={4}>
            <Text color={theme.textDim}>
              Best for: Fault-tolerant, distributed multi-agent systems
            </Text>
          </Box>
        </Box>
      </Box>
      <Newline />

      {selectedTrack ? (
        <Text color={theme.success}>
          Selected: {selectedTrack.toUpperCase()} Track — Press → to continue
        </Text>
      ) : (
        <Text color={theme.textDim}>Press 1, 2, or 3 to select a track</Text>
      )}
    </Box>
  );
}

function Step1ShowCode({ track }: { track: 'unix' | 'sdk' | 'beam' | null }) {
  const code = track === 'unix' ? UNIX_AGENT_CODE
    : track === 'beam' ? BEAM_AGENT_CODE
    : SDK_AGENT_CODE;

  const title = track === 'unix' ? 'Unix Agent (Bash)'
    : track === 'beam' ? 'BEAM Agent (Elixir/Jido)'
    : 'SDK Agent (TypeScript)';

  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>{title}</Text>
      <Newline />

      <Box
        borderStyle="round"
        borderColor={theme.textDim}
        paddingX={1}
        flexDirection="column"
      >
        <Text color={theme.secondary}>{code}</Text>
      </Box>
    </Box>
  );
}

function Step2NextSteps({ track }: { track: 'unix' | 'sdk' | 'beam' | null }) {
  const steps = track === 'unix' ? [
    'Add tool parsing with grep/sed for <tool_call> tags',
    'Implement history management with temp files',
    'Add error handling for API failures',
    'Create tool executor functions (read_file, write_file, etc.)',
  ] : track === 'beam' ? [
    'Set up a new Phoenix/Elixir project',
    'Add Jido and configure supervisors',
    'Define agent schemas and actions',
    'Implement the Claude API integration',
    'Add LiveView for real-time UI',
  ] : [
    'Install @anthropic-ai/sdk package',
    'Define your tool schemas',
    'Implement tool execution handlers',
    'Add context management for long conversations',
    'Consider adding memory/state persistence',
  ];

  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>Next Steps for {track?.toUpperCase()} Track</Text>
      <Newline />

      <Box flexDirection="column" marginLeft={2}>
        {steps.map((step, i) => (
          <Text key={i} color={theme.textMuted}>
            {i + 1}. {step}
          </Text>
        ))}
      </Box>
      <Newline />

      <Box borderStyle="round" borderColor={theme.info} paddingX={2}>
        <Text color={theme.info}>
          {icons.star} Pro tip: Start with the simplest version that works,
          then add complexity only when needed. Remember the Bitter Lesson!
        </Text>
      </Box>
    </Box>
  );
}

function Step3Summary() {
  return (
    <Box flexDirection="column">
      <Text color={theme.accent} bold>{icons.star} Congratulations!</Text>
      <Newline />

      <Text color={theme.text}>
        You've completed the Agent Architecture Tutorial. Here's what you learned:
      </Text>
      <Newline />

      <Box flexDirection="column" marginLeft={2} gap={1}>
        <Text color={theme.success}>
          {icons.check} <Text bold>Lesson 1:</Text> The agent loop is just a while loop
        </Text>
        <Text color={theme.success}>
          {icons.check} <Text bold>Lesson 2:</Text> Context engineering is the key skill
        </Text>
        <Text color={theme.success}>
          {icons.check} <Text bold>Lesson 3:</Text> Multi-agent needs central planning
        </Text>
        <Text color={theme.success}>
          {icons.check} <Text bold>Lesson 4:</Text> Generic tools beat specialized ones
        </Text>
        <Text color={theme.success}>
          {icons.check} <Text bold>Lesson 5:</Text> Start simple, add complexity as needed
        </Text>
      </Box>
      <Newline />

      <Box borderStyle="double" borderColor={theme.primary} paddingX={2} paddingY={1}>
        <Box flexDirection="column">
          <Text color={theme.primary} bold>The Central Thesis:</Text>
          <Newline />
          <Text color={theme.text}>
            "All agents will become coding agents."
          </Text>
          <Newline />
          <Text color={theme.textMuted}>
            The LLM + Computer architecture is exceptionally powerful
            regardless of whether your task involves writing code.
          </Text>
        </Box>
      </Box>
      <Newline />

      <Text color={theme.textMuted}>
        Press → to exit, or explore the example files in ./examples/
      </Text>
    </Box>
  );
}
