#!/bin/bash
#
# Unix Track: Minimal Agent using Bash
# =====================================
# A complete agent implementation using only bash, curl, and jq.
#
# Prerequisites:
#   - curl
#   - jq
#   - ANTHROPIC_API_KEY environment variable set
#
# Usage:
#   ./unix-agent.sh "What is the capital of France?"
#   ./unix-agent.sh "Read the file package.json and summarize it"
#

set -euo pipefail

# Require API key
ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:?Error: Set ANTHROPIC_API_KEY environment variable}"

# Configuration
MODEL="claude-sonnet-4-20250514"
MAX_TOKENS=1024
HISTORY_FILE="/tmp/agent_history_$$.json"

# Initialize history
echo '[]' > "$HISTORY_FILE"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_tool() { echo -e "${YELLOW}[TOOL]${NC} $1"; }

# Tool definitions for the API
TOOLS='[
  {
    "name": "read_file",
    "description": "Read the contents of a file at the given path",
    "input_schema": {
      "type": "object",
      "properties": {
        "path": {
          "type": "string",
          "description": "The file path to read"
        }
      },
      "required": ["path"]
    }
  },
  {
    "name": "write_file",
    "description": "Write content to a file at the given path",
    "input_schema": {
      "type": "object",
      "properties": {
        "path": {
          "type": "string",
          "description": "The file path to write to"
        },
        "content": {
          "type": "string",
          "description": "The content to write"
        }
      },
      "required": ["path", "content"]
    }
  },
  {
    "name": "run_command",
    "description": "Run a shell command and return the output",
    "input_schema": {
      "type": "object",
      "properties": {
        "command": {
          "type": "string",
          "description": "The shell command to execute"
        }
      },
      "required": ["command"]
    }
  },
  {
    "name": "list_files",
    "description": "List files in a directory",
    "input_schema": {
      "type": "object",
      "properties": {
        "path": {
          "type": "string",
          "description": "The directory path (defaults to current directory)"
        }
      }
    }
  }
]'

# Execute a tool based on name and input
execute_tool() {
  local tool_name="$1"
  local tool_input="$2"

  case "$tool_name" in
    read_file)
      local path
      path=$(echo "$tool_input" | jq -r '.path')
      log_tool "Reading file: $path"
      if [[ -f "$path" ]]; then
        cat "$path"
      else
        echo "Error: File not found: $path"
      fi
      ;;

    write_file)
      local path content
      path=$(echo "$tool_input" | jq -r '.path')
      content=$(echo "$tool_input" | jq -r '.content')
      log_tool "Writing to file: $path"
      echo "$content" > "$path"
      echo "Successfully wrote to $path"
      ;;

    run_command)
      local command
      command=$(echo "$tool_input" | jq -r '.command')
      log_tool "Running command: $command"
      # Run command with timeout and capture output
      timeout 30 bash -c "$command" 2>&1 || echo "Command failed or timed out"
      ;;

    list_files)
      local path
      path=$(echo "$tool_input" | jq -r '.path // "."')
      log_tool "Listing files in: $path"
      ls -la "$path" 2>&1 || echo "Error: Could not list directory"
      ;;

    *)
      echo "Unknown tool: $tool_name"
      ;;
  esac
}

# Call the Claude API
call_api() {
  local messages="$1"

  local response
  response=$(curl -s https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "content-type: application/json" \
    -H "anthropic-version: 2023-06-01" \
    -d "$(jq -n \
      --arg model "$MODEL" \
      --argjson max_tokens "$MAX_TOKENS" \
      --argjson messages "$messages" \
      --argjson tools "$TOOLS" \
      '{
        model: $model,
        max_tokens: $max_tokens,
        tools: $tools,
        messages: $messages
      }')")

  echo "$response"
}

# Add a message to history
add_to_history() {
  local role="$1"
  local content="$2"

  local current
  current=$(cat "$HISTORY_FILE")

  echo "$current" | jq \
    --arg role "$role" \
    --arg content "$content" \
    '. + [{"role": $role, "content": $content}]' > "$HISTORY_FILE"
}

# Add a message with complex content (for tool results)
add_complex_to_history() {
  local role="$1"
  local content="$2"  # Already JSON

  local current
  current=$(cat "$HISTORY_FILE")

  echo "$current" | jq \
    --arg role "$role" \
    --argjson content "$content" \
    '. + [{"role": $role, "content": $content}]' > "$HISTORY_FILE"
}

# Main agent loop
run_agent() {
  local user_input="$1"

  log_info "Starting agent with task: $user_input"
  add_to_history "user" "$user_input"

  local iteration=0
  local max_iterations=10

  while [[ $iteration -lt $max_iterations ]]; do
    ((iteration++))
    log_info "Iteration $iteration/$max_iterations"

    # Get current history
    local messages
    messages=$(cat "$HISTORY_FILE")

    # Call the API
    local response
    response=$(call_api "$messages")

    # Check for errors
    if echo "$response" | jq -e '.error' > /dev/null 2>&1; then
      log_error "API Error: $(echo "$response" | jq -r '.error.message')"
      return 1
    fi

    # Get the content array
    local content
    content=$(echo "$response" | jq '.content')

    # Check stop reason
    local stop_reason
    stop_reason=$(echo "$response" | jq -r '.stop_reason')

    # Add assistant response to history
    add_complex_to_history "assistant" "$content"

    if [[ "$stop_reason" == "end_turn" ]]; then
      # Final response - extract text
      local final_text
      final_text=$(echo "$content" | jq -r '.[] | select(.type == "text") | .text')
      log_success "Agent completed"
      echo ""
      echo "$final_text"
      return 0
    fi

    if [[ "$stop_reason" == "tool_use" ]]; then
      # Process tool calls
      local tool_results='[]'

      while read -r tool_call; do
        local tool_id tool_name tool_input
        tool_id=$(echo "$tool_call" | jq -r '.id')
        tool_name=$(echo "$tool_call" | jq -r '.name')
        tool_input=$(echo "$tool_call" | jq '.input')

        log_info "Executing tool: $tool_name"

        # Execute the tool
        local result
        result=$(execute_tool "$tool_name" "$tool_input")

        # Add to tool results
        tool_results=$(echo "$tool_results" | jq \
          --arg id "$tool_id" \
          --arg content "$result" \
          '. + [{"type": "tool_result", "tool_use_id": $id, "content": $content}]')
      done < <(echo "$content" | jq -c '.[] | select(.type == "tool_use")')

      # Add tool results to history
      add_complex_to_history "user" "$tool_results"
    else
      log_error "Unexpected stop reason: $stop_reason"
      return 1
    fi
  done

  log_error "Max iterations reached"
  return 1
}

# Cleanup on exit
cleanup() {
  rm -f "$HISTORY_FILE"
}
trap cleanup EXIT

# Main entry point
main() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <task>"
    echo ""
    echo "Examples:"
    echo "  $0 \"What is 2 + 2?\""
    echo "  $0 \"List the files in the current directory\""
    echo "  $0 \"Read package.json and tell me the project name\""
    exit 1
  fi

  run_agent "$*"
}

main "$@"
