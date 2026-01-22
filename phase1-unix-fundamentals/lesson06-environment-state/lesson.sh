#!/bin/bash
#
# Lesson 06: Environment and State
# ==================================
# How Unix processes manage configuration and state.
# Environment variables for config, files for persistence.
#
# Run: ./lesson.sh
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

STEP=0
TOTAL_STEPS=8

print_header() {
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  LESSON 06: Environment and State${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
}

print_nav() {
    echo
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  Step $((STEP+1))/$TOTAL_STEPS  ${DIM}|${NC}  ${GREEN}[n]${NC} Next  ${GREEN}[p]${NC} Previous  ${GREEN}[q]${NC} Quit"
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

wait_for_key() {
    local key
    read -rsn1 key
    case "$key" in
        n|N|'') [[ $STEP -lt $((TOTAL_STEPS-1)) ]] && ((STEP++)) ;;
        p|P) [[ $STEP -gt 0 ]] && ((STEP--)) ;;
        q|Q) echo; echo -e "${GREEN}Lesson complete.${NC}"; exit 0 ;;
    esac
}

# -----------------------------------------------------------------------------
# STEP 0: Introduction
# -----------------------------------------------------------------------------
step_intro() {
    print_header

    echo -e "${BOLD}Environment Variables${NC}"
    echo
    echo "Environment variables are key-value pairs inherited"
    echo "by child processes from their parent."
    echo
    echo -e "  ${CYAN}•${NC} Configuration without files"
    echo -e "  ${CYAN}•${NC} Passed from parent to child"
    echo -e "  ${CYAN}•${NC} Not shared between siblings"
    echo -e "  ${CYAN}•${NC} Changes don't propagate upward"
    echo
    echo -e "${YELLOW}► Exercise: See your environment${NC}"
    echo
    echo -e "${DIM}Command:${NC} env | head -10"
    echo
    env | head -10
    echo "..."
    echo
    echo -e "${YELLOW}Why this matters for agents:${NC}"
    echo "API keys, model names, config - all pass through environment."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 1: Setting variables
# -----------------------------------------------------------------------------
step_setting() {
    print_header

    echo -e "${BOLD}Setting Environment Variables${NC}"
    echo
    echo -e "${CYAN}Shell variable (local):${NC}"
    echo "  MY_VAR='value'           # Only in this shell"
    echo
    echo -e "${CYAN}Environment variable (inherited):${NC}"
    echo "  export MY_VAR='value'    # Passed to children"
    echo
    echo -e "${CYAN}For one command only:${NC}"
    echo "  MY_VAR='value' command   # Only for this command"
    echo
    echo -e "${YELLOW}► Exercise: Variable inheritance${NC}"
    echo
    MY_LOCAL="I am local"
    export MY_EXPORTED="I am exported"
    echo -e "${DIM}Command:${NC} bash -c 'echo \"\$MY_LOCAL / \$MY_EXPORTED\"'"
    echo
    echo -e "${CYAN}Result:${NC} $(bash -c 'echo "$MY_LOCAL / $MY_EXPORTED"')"
    echo
    echo "Only exported variables appear in child processes."
    echo
    echo -e "${YELLOW}► One-shot export:${NC}"
    echo
    echo -e "${DIM}Command:${NC} TEMP_VAR=hello bash -c 'echo \$TEMP_VAR'"
    echo -e "${CYAN}Result:${NC} $(TEMP_VAR=hello bash -c 'echo $TEMP_VAR')"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 2: Common variables
# -----------------------------------------------------------------------------
step_common_vars() {
    print_header

    echo -e "${BOLD}Common Environment Variables${NC}"
    echo
    echo -e "${GREEN}PATH${NC} - Where to find executables"
    echo "  Current: ${PATH:0:50}..."
    echo
    echo -e "${GREEN}HOME${NC} - User's home directory"
    echo "  Current: $HOME"
    echo
    echo -e "${GREEN}USER${NC} - Current username"
    echo "  Current: $USER"
    echo
    echo -e "${GREEN}PWD${NC} - Current working directory"
    echo "  Current: $PWD"
    echo
    echo -e "${GREEN}SHELL${NC} - Default shell"
    echo "  Current: $SHELL"
    echo
    echo -e "${YELLOW}Agent-relevant variables:${NC}"
    echo
    echo -e "  ${GREEN}OPENAI_API_KEY${NC}    - API authentication"
    echo -e "  ${GREEN}ANTHROPIC_API_KEY${NC} - API authentication"
    echo -e "  ${GREEN}MODEL${NC}             - Which model to use"
    echo -e "  ${GREEN}DEBUG${NC}             - Enable debug output"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 3: Reading process environment
# -----------------------------------------------------------------------------
step_proc_environ() {
    print_header

    echo -e "${BOLD}Observing Process Environment${NC}"
    echo
    echo "Every process's environment is in /proc/PID/environ:"
    echo
    echo -e "${YELLOW}► Exercise: Read this script's environment${NC}"
    echo
    echo -e "${DIM}Command:${NC} cat /proc/\$\$/environ | tr '\\0' '\\n' | head -5"
    echo
    if [[ -r /proc/$$/environ ]]; then
        cat /proc/$$/environ | tr '\0' '\n' | head -5
    else
        echo "(Cannot read on this system)"
    fi
    echo "..."
    echo
    echo -e "${GREEN}This lets you inspect any process's config!${NC}"
    echo
    echo -e "${YELLOW}► Useful for debugging agents:${NC}"
    echo "  # What API key is the agent using?"
    echo "  cat /proc/\$AGENT_PID/environ | tr '\\0' '\\n' | grep API_KEY"
    echo
    echo "  # What model is configured?"
    echo "  cat /proc/\$AGENT_PID/environ | tr '\\0' '\\n' | grep MODEL"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 4: Files as state
# -----------------------------------------------------------------------------
step_files_state() {
    print_header

    echo -e "${BOLD}Files as State${NC}"
    echo
    echo "Unix processes persist state to files:"
    echo
    echo -e "  ${GREEN}Plain text${NC}     - Human readable, easy to debug"
    echo -e "  ${GREEN}JSON/YAML${NC}      - Structured, tool-friendly"
    echo -e "  ${GREEN}SQLite${NC}         - Query-able, transactional"
    echo -e "  ${GREEN}Append-only${NC}    - Logs, conversation history"
    echo
    echo -e "${YELLOW}► Exercise: Inspect file-based state${NC}"
    echo
    local tmpfile=$(mktemp)
    cat > "$tmpfile" << 'EOF'
{"turn": 1, "role": "user", "content": "Hello"}
{"turn": 2, "role": "assistant", "content": "Hi there!"}
{"turn": 3, "role": "user", "content": "How are you?"}
EOF
    echo -e "${DIM}File: conversation.jsonl${NC}"
    echo
    cat "$tmpfile"
    echo
    echo -e "${GREEN}JSON Lines format:${NC}"
    echo "  - One JSON object per line"
    echo "  - Easy to append: echo '{...}' >> file"
    echo "  - Easy to read: while read line; do ..."
    echo "  - Easy to observe: tail -f conversation.jsonl"
    rm -f "$tmpfile"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 5: Lock files
# -----------------------------------------------------------------------------
step_lockfiles() {
    print_header

    echo -e "${BOLD}Lock Files and Coordination${NC}"
    echo
    echo "Lock files prevent multiple processes from conflicting:"
    echo
    cat << 'EOF'
  #!/bin/bash
  LOCKFILE="/tmp/myagent.lock"

  # Try to acquire lock
  if ! mkdir "$LOCKFILE" 2>/dev/null; then
      echo "Another instance is running" >&2
      exit 1
  fi

  # Ensure cleanup
  trap 'rmdir "$LOCKFILE"' EXIT

  # ... do work ...
EOF
    echo
    echo -e "${YELLOW}Why mkdir?${NC}"
    echo "mkdir is atomic - it either succeeds or fails."
    echo "Two processes can't both create the same directory."
    echo
    echo -e "${YELLOW}► PID files:${NC}"
    echo "  echo \$\$ > /var/run/myagent.pid"
    echo
    echo "This records which PID holds the lock."
    echo "You can check if that PID still exists with kill -0."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 6: XDG directories
# -----------------------------------------------------------------------------
step_xdg() {
    print_header

    echo -e "${BOLD}XDG Base Directory Standard${NC}"
    echo
    echo "Standard locations for application data:"
    echo
    echo -e "  ${GREEN}XDG_CONFIG_HOME${NC} - Configuration files"
    echo "    Default: ~/.config"
    echo "    Current: ${XDG_CONFIG_HOME:-~/.config}"
    echo
    echo -e "  ${GREEN}XDG_DATA_HOME${NC} - Application data"
    echo "    Default: ~/.local/share"
    echo "    Current: ${XDG_DATA_HOME:-~/.local/share}"
    echo
    echo -e "  ${GREEN}XDG_STATE_HOME${NC} - State (logs, history)"
    echo "    Default: ~/.local/state"
    echo "    Current: ${XDG_STATE_HOME:-~/.local/state}"
    echo
    echo -e "  ${GREEN}XDG_CACHE_HOME${NC} - Cache (can be deleted)"
    echo "    Default: ~/.cache"
    echo "    Current: ${XDG_CACHE_HOME:-~/.cache}"
    echo
    echo -e "${YELLOW}Agent example:${NC}"
    echo "  CONFIG=\${XDG_CONFIG_HOME:-~/.config}/myagent"
    echo "  STATE=\${XDG_STATE_HOME:-~/.local/state}/myagent"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 7: State patterns
# -----------------------------------------------------------------------------
step_patterns() {
    print_header

    echo -e "${BOLD}State Patterns for Agents${NC}"
    echo
    echo -e "${CYAN}Pattern 1: Context as append-only file${NC}"
    echo "  echo '{\"role\":\"user\",\"content\":\"...\"}' >> context.jsonl"
    echo
    echo -e "${CYAN}Pattern 2: Tool results in temp directory${NC}"
    echo "  WORK_DIR=\$(mktemp -d)"
    echo "  trap 'rm -rf \$WORK_DIR' EXIT"
    echo "  tool_output > \"\$WORK_DIR/result.json\""
    echo
    echo -e "${CYAN}Pattern 3: Session ID in environment${NC}"
    echo "  export SESSION_ID=\$(uuidgen)"
    echo "  # All child processes share the session"
    echo
    echo -e "${CYAN}Pattern 4: Watch file for changes${NC}"
    echo "  inotifywait -m state.json | while read event; do"
    echo "      reload_state"
    echo "  done"
    echo
    echo -e "${YELLOW}Key insight:${NC}"
    echo "Files = observable state"
    echo "Environment = observable configuration"
    echo "Both can be inspected with standard Unix tools."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 8: Summary
# -----------------------------------------------------------------------------
step_summary() {
    print_header

    echo -e "${BOLD}Summary: Environment and State${NC}"
    echo
    echo -e "${GREEN}✓${NC} Environment variables configure processes"
    echo -e "${GREEN}✓${NC} export makes variables inherited"
    echo -e "${GREEN}✓${NC} /proc/PID/environ shows any process's env"
    echo -e "${GREEN}✓${NC} Files persist state beyond process lifetime"
    echo -e "${GREEN}✓${NC} Lock files coordinate between processes"
    echo
    echo -e "${CYAN}Environment toolkit:${NC}"
    echo
    echo "  env                        # Show all vars"
    echo "  export VAR=value           # Make inheritable"
    echo "  VAR=value command          # One-shot export"
    echo "  printenv VAR               # Get specific var"
    echo "  cat /proc/PID/environ      # Inspect process"
    echo
    echo -e "${CYAN}State toolkit:${NC}"
    echo
    echo "  echo data >> state.log     # Append-only"
    echo "  mkdir lockdir              # Atomic lock"
    echo "  mktemp -d                  # Temp workspace"
    echo
    echo -e "${YELLOW}Next lesson:${NC} Process Supervision"

    print_nav
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------
main() {
    while true; do
        case $STEP in
            0) step_intro ;;
            1) step_setting ;;
            2) step_common_vars ;;
            3) step_proc_environ ;;
            4) step_files_state ;;
            5) step_lockfiles ;;
            6) step_xdg ;;
            7) step_patterns ;;
            *) step_summary ;;
        esac
        wait_for_key
    done
}

main
