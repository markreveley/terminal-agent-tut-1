/**
 * SDK Track: Agent using the Anthropic TypeScript SDK
 * ====================================================
 *
 * A complete agent implementation using the official Anthropic SDK
 * with proper tool definitions and the agentic loop pattern.
 *
 * Prerequisites:
 *   npm install @anthropic-ai/sdk
 *   Set ANTHROPIC_API_KEY environment variable
 *
 * Usage:
 *   npx tsx examples/sdk-agent.ts "What files are in this directory?"
 */

import Anthropic from "@anthropic-ai/sdk";
import * as fs from "fs";
import * as path from "path";
import { execSync } from "child_process";

// Initialize the client
const client = new Anthropic();

// Define the tools available to the agent
const tools: Anthropic.Tool[] = [
  {
    name: "read_file",
    description:
      "Read the contents of a file at the specified path. Returns the file contents as a string.",
    input_schema: {
      type: "object" as const,
      properties: {
        path: {
          type: "string",
          description: "The path to the file to read",
        },
      },
      required: ["path"],
    },
  },
  {
    name: "write_file",
    description:
      "Write content to a file at the specified path. Creates the file if it doesn't exist.",
    input_schema: {
      type: "object" as const,
      properties: {
        path: {
          type: "string",
          description: "The path to the file to write",
        },
        content: {
          type: "string",
          description: "The content to write to the file",
        },
      },
      required: ["path", "content"],
    },
  },
  {
    name: "list_directory",
    description:
      "List the contents of a directory. Returns file names and whether each is a file or directory.",
    input_schema: {
      type: "object" as const,
      properties: {
        path: {
          type: "string",
          description:
            "The directory path to list (defaults to current directory)",
        },
      },
    },
  },
  {
    name: "run_command",
    description:
      "Execute a shell command and return its output. Use for operations like git, npm, etc.",
    input_schema: {
      type: "object" as const,
      properties: {
        command: {
          type: "string",
          description: "The shell command to execute",
        },
      },
      required: ["command"],
    },
  },
  {
    name: "search_files",
    description: "Search for files matching a glob pattern in the directory.",
    input_schema: {
      type: "object" as const,
      properties: {
        pattern: {
          type: "string",
          description: "Glob pattern to match (e.g., '**/*.ts', '*.json')",
        },
        directory: {
          type: "string",
          description: "Directory to search in (defaults to current directory)",
        },
      },
      required: ["pattern"],
    },
  },
];

// Tool execution handlers
type ToolInput = Record<string, unknown>;

function executeTool(name: string, input: ToolInput): string {
  console.log(`\x1b[33m[TOOL]\x1b[0m Executing: ${name}`);

  switch (name) {
    case "read_file": {
      const filePath = input.path as string;
      try {
        const content = fs.readFileSync(filePath, "utf-8");
        console.log(`\x1b[32m[SUCCESS]\x1b[0m Read ${content.length} bytes`);
        return content;
      } catch (error) {
        return `Error reading file: ${(error as Error).message}`;
      }
    }

    case "write_file": {
      const filePath = input.path as string;
      const content = input.content as string;
      try {
        // Ensure directory exists
        const dir = path.dirname(filePath);
        if (!fs.existsSync(dir)) {
          fs.mkdirSync(dir, { recursive: true });
        }
        fs.writeFileSync(filePath, content);
        console.log(`\x1b[32m[SUCCESS]\x1b[0m Wrote to ${filePath}`);
        return `Successfully wrote ${content.length} bytes to ${filePath}`;
      } catch (error) {
        return `Error writing file: ${(error as Error).message}`;
      }
    }

    case "list_directory": {
      const dirPath = (input.path as string) || ".";
      try {
        const entries = fs.readdirSync(dirPath, { withFileTypes: true });
        const result = entries
          .map((entry) => {
            const type = entry.isDirectory() ? "[DIR]" : "[FILE]";
            return `${type} ${entry.name}`;
          })
          .join("\n");
        console.log(`\x1b[32m[SUCCESS]\x1b[0m Listed ${entries.length} items`);
        return result;
      } catch (error) {
        return `Error listing directory: ${(error as Error).message}`;
      }
    }

    case "run_command": {
      const command = input.command as string;
      try {
        const output = execSync(command, {
          encoding: "utf-8",
          timeout: 30000,
          maxBuffer: 1024 * 1024,
        });
        console.log(`\x1b[32m[SUCCESS]\x1b[0m Command completed`);
        return output;
      } catch (error) {
        const execError = error as { stderr?: string; message: string };
        return `Command failed: ${execError.stderr || execError.message}`;
      }
    }

    case "search_files": {
      const pattern = input.pattern as string;
      const directory = (input.directory as string) || ".";
      try {
        // Use find command for glob matching
        const output = execSync(
          `find ${directory} -name "${pattern}" -type f 2>/dev/null | head -50`,
          { encoding: "utf-8" }
        );
        console.log(`\x1b[32m[SUCCESS]\x1b[0m Search completed`);
        return output || "No files found matching pattern";
      } catch {
        return "No files found matching pattern";
      }
    }

    default:
      return `Unknown tool: ${name}`;
  }
}

// The main agent function
async function runAgent(task: string): Promise<string> {
  console.log(`\x1b[34m[INFO]\x1b[0m Starting agent with task: ${task}\n`);

  // Initialize the conversation
  const messages: Anthropic.MessageParam[] = [
    {
      role: "user",
      content: task,
    },
  ];

  let iteration = 0;
  const maxIterations = 10;

  // The agentic loop
  while (iteration < maxIterations) {
    iteration++;
    console.log(
      `\x1b[34m[INFO]\x1b[0m Iteration ${iteration}/${maxIterations}`
    );

    // Call the API
    const response = await client.messages.create({
      model: "claude-sonnet-4-20250514",
      max_tokens: 4096,
      tools,
      messages,
    });

    // Check if we're done
    if (response.stop_reason === "end_turn") {
      // Extract the final text response
      const textBlock = response.content.find((block) => block.type === "text");
      if (textBlock && textBlock.type === "text") {
        console.log(`\n\x1b[32m[COMPLETE]\x1b[0m Agent finished\n`);
        return textBlock.text;
      }
      return "Agent completed without text response";
    }

    // Process tool use
    if (response.stop_reason === "tool_use") {
      // Add assistant's response to messages
      messages.push({
        role: "assistant",
        content: response.content,
      });

      // Execute all tool calls and collect results
      const toolResults: Anthropic.ToolResultBlockParam[] = [];

      for (const block of response.content) {
        if (block.type === "tool_use") {
          const result = executeTool(
            block.name,
            block.input as Record<string, unknown>
          );
          toolResults.push({
            type: "tool_result",
            tool_use_id: block.id,
            content: result,
          });
        }
      }

      // Add tool results to messages
      messages.push({
        role: "user",
        content: toolResults,
      });
    }
  }

  return "Max iterations reached without completion";
}

// Main entry point
async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log("Usage: npx tsx examples/sdk-agent.ts <task>");
    console.log("");
    console.log("Examples:");
    console.log(
      '  npx tsx examples/sdk-agent.ts "What files are in this directory?"'
    );
    console.log(
      '  npx tsx examples/sdk-agent.ts "Read package.json and summarize it"'
    );
    console.log(
      '  npx tsx examples/sdk-agent.ts "Create a hello.txt file with a greeting"'
    );
    process.exit(1);
  }

  const task = args.join(" ");

  try {
    const result = await runAgent(task);
    console.log("─".repeat(60));
    console.log("\nResult:\n");
    console.log(result);
  } catch (error) {
    console.error("\x1b[31m[ERROR]\x1b[0m", (error as Error).message);
    process.exit(1);
  }
}

main();
