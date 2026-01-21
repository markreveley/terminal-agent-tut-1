#!/usr/bin/env node
import React, { useState } from 'react';
import { render, Box, Text } from 'ink';
import { Home } from './components/Home.js';
import { Lesson1AgentLoop } from './lessons/Lesson1AgentLoop.js';
import { Lesson2ContextEngineering } from './lessons/Lesson2ContextEngineering.js';
import { Lesson3MultiAgent } from './lessons/Lesson3MultiAgent.js';
import { Lesson4ClaudeCode } from './lessons/Lesson4ClaudeCode.js';
import { Lesson5BuildAgent } from './lessons/Lesson5BuildAgent.js';
import { theme } from './utils/theme.js';

type Screen = 'home' | 'lesson1' | 'lesson2' | 'lesson3' | 'lesson4' | 'lesson5' | 'complete';

function App() {
  const [screen, setScreen] = useState<Screen>('home');

  const goToLesson = (num: number) => {
    setScreen(`lesson${num}` as Screen);
  };

  const nextLesson = (current: number) => {
    if (current < 5) {
      setScreen(`lesson${current + 1}` as Screen);
    } else {
      setScreen('complete');
    }
  };

  const prevLesson = (current: number) => {
    if (current > 1) {
      setScreen(`lesson${current - 1}` as Screen);
    } else {
      setScreen('home');
    }
  };

  return (
    <Box flexDirection="column">
      {screen === 'home' && (
        <Home onSelectLesson={goToLesson} />
      )}

      {screen === 'lesson1' && (
        <Lesson1AgentLoop
          onNext={() => nextLesson(1)}
          onBack={() => prevLesson(1)}
        />
      )}

      {screen === 'lesson2' && (
        <Lesson2ContextEngineering
          onNext={() => nextLesson(2)}
          onBack={() => prevLesson(2)}
        />
      )}

      {screen === 'lesson3' && (
        <Lesson3MultiAgent
          onNext={() => nextLesson(3)}
          onBack={() => prevLesson(3)}
        />
      )}

      {screen === 'lesson4' && (
        <Lesson4ClaudeCode
          onNext={() => nextLesson(4)}
          onBack={() => prevLesson(4)}
        />
      )}

      {screen === 'lesson5' && (
        <Lesson5BuildAgent
          onComplete={() => setScreen('complete')}
          onBack={() => prevLesson(5)}
        />
      )}

      {screen === 'complete' && (
        <CompletionScreen onRestart={() => setScreen('home')} />
      )}
    </Box>
  );
}

function CompletionScreen({ onRestart }: { onRestart: () => void }) {
  React.useEffect(() => {
    const handler = (data: Buffer) => {
      const key = data.toString();
      if (key === 'r') {
        onRestart();
      }
      if (key === 'q' || key === '\u0003') {
        process.exit(0);
      }
    };

    process.stdin.on('data', handler);
    return () => {
      process.stdin.off('data', handler);
    };
  }, [onRestart]);

  return (
    <Box flexDirection="column" paddingX={2} paddingY={1}>
      <Box justifyContent="center">
        <Text color={theme.success} bold>
          🎉 Tutorial Complete! 🎉
        </Text>
      </Box>
      <Text> </Text>

      <Text color={theme.text}>
        You now understand the foundations of modern agent architecture.
      </Text>
      <Text> </Text>

      <Text color={theme.accent} bold>What's Next?</Text>
      <Text> </Text>

      <Box flexDirection="column" marginLeft={2}>
        <Text color={theme.textMuted}>
          • Explore ./examples/ for working code samples
        </Text>
        <Text color={theme.textMuted}>
          • Try building an agent with the Anthropic SDK
        </Text>
        <Text color={theme.textMuted}>
          • Read the full research synthesis in the docs
        </Text>
        <Text color={theme.textMuted}>
          • Experiment with Claude Code on your own projects
        </Text>
      </Box>
      <Text> </Text>

      <Box gap={3}>
        <Box>
          <Text color={theme.info}>[r]</Text>
          <Text color={theme.textMuted}> Restart tutorial</Text>
        </Box>
        <Box>
          <Text color={theme.error}>[q]</Text>
          <Text color={theme.textMuted}> Quit</Text>
        </Box>
      </Box>
    </Box>
  );
}

// Start the application
render(<App />);
