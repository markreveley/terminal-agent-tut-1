#!/bin/bash
#
# Lesson 07: Process Supervision
# ================================
# Keeping processes alive, restarting on failure, and
# managing process lifecycles. The foundation for
# fault-tolerant agent systems.
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
    echo -e "${BOLD}  LESSON 07: Process Supervision${NC}"
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

    echo -e "${BOLD}What is Process Supervision?${NC}"
    echo
    echo "A supervisor watches processes and acts on failures:"
    echo
    echo -e "  ${CYAN}•${NC} Starts processes on boot"
    echo -e "  ${CYAN}•${NC} Restarts crashed processes"
    echo -e "  ${CYAN}•${NC} Stops processes gracefully"
    echo -e "  ${CYAN}•${NC} Provides process status"
    echo
    echo -e "${YELLOW}The Supervision Hierarchy:${NC}"
    echo
    echo "  systemd (PID 1)"
    echo "    └── myagent.service"
    echo "          └── orchestrator"
    echo "                ├── subagent-1"
    echo "                ├── subagent-2"
    echo "                └── tool-runner"
    echo
    echo -e "${YELLOW}Why this matters:${NC}"
    echo "Agents crash. Networks fail. APIs timeout."
    echo "Supervision means: \"Crash and let someone restart you.\""
    echo "This is simpler than defensive programming everywhere."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 1: Simple restart loop
# -----------------------------------------------------------------------------
step_restart_loop() {
    print_header

    echo -e "${BOLD}Simplest Supervisor: A While Loop${NC}"
    echo
    cat << 'EOF'
  #!/bin/bash
  # supervisor.sh - Restart worker forever

  while true; do
      echo "[$(date)] Starting worker..."
      ./worker.sh
      EXIT_CODE=$?
      echo "[$(date)] Worker exited with code $EXIT_CODE"
      sleep 1  # Brief pause before restart
  done
EOF
    echo
    echo -e "${YELLOW}► This is a real supervisor!${NC}"
    echo
    echo "It's simple but has problems:"
    echo "  - Can't stop gracefully"
    echo "  - No backoff on repeated failures"
    echo "  - No status reporting"
    echo
    echo -e "${GREEN}Let's improve it step by step...${NC}"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 2: Graceful shutdown
# -----------------------------------------------------------------------------
step_graceful() {
    print_header

    echo -e "${BOLD}Adding Graceful Shutdown${NC}"
    echo
    cat << 'EOF'
  #!/bin/bash
  # supervisor.sh - With graceful shutdown

  WORKER_PID=""
  RUNNING=true

  cleanup() {
      RUNNING=false
      if [[ -n "$WORKER_PID" ]]; then
          echo "Stopping worker $WORKER_PID..."
          kill -TERM "$WORKER_PID" 2>/dev/null
          wait "$WORKER_PID" 2>/dev/null
      fi
      echo "Supervisor exiting."
      exit 0
  }

  trap cleanup SIGTERM SIGINT

  while $RUNNING; do
      ./worker.sh &
      WORKER_PID=$!
      wait $WORKER_PID
      WORKER_PID=""
      $RUNNING && sleep 1
  done
EOF
    echo
    echo -e "${YELLOW}Key improvements:${NC}"
    echo "  1. Trap SIGTERM/SIGINT"
    echo "  2. Forward signal to worker"
    echo "  3. Wait for worker to exit"
    echo "  4. Clean shutdown on signal"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 3: Backoff strategy
# -----------------------------------------------------------------------------
step_backoff() {
    print_header

    echo -e "${BOLD}Exponential Backoff${NC}"
    echo
    echo "If a process keeps crashing, don't restart immediately:"
    echo
    cat << 'EOF'
  #!/bin/bash
  BACKOFF=1
  MAX_BACKOFF=60

  while true; do
      START=$(date +%s)
      ./worker.sh
      END=$(date +%s)
      RUNTIME=$((END - START))

      if [[ $RUNTIME -lt 5 ]]; then
          # Crashed quickly - increase backoff
          echo "Quick crash, waiting ${BACKOFF}s..."
          sleep $BACKOFF
          BACKOFF=$((BACKOFF * 2))
          [[ $BACKOFF -gt $MAX_BACKOFF ]] && BACKOFF=$MAX_BACKOFF
      else
          # Ran for a while - reset backoff
          BACKOFF=1
      fi
  done
EOF
    echo
    echo -e "${YELLOW}Why backoff matters:${NC}"
    echo "Without it, a broken agent can:"
    echo "  - Burn API rate limits"
    echo "  - Fill logs with crash spam"
    echo "  - Never give you time to fix it"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 4: Job control
# -----------------------------------------------------------------------------
step_job_control() {
    print_header

    echo -e "${BOLD}Shell Job Control${NC}"
    echo
    echo "The shell has built-in process management:"
    echo
    echo -e "  ${GREEN}cmd &${NC}      - Run in background"
    echo -e "  ${GREEN}jobs${NC}       - List background jobs"
    echo -e "  ${GREEN}fg %N${NC}      - Bring job N to foreground"
    echo -e "  ${GREEN}bg %N${NC}      - Resume job N in background"
    echo -e "  ${GREEN}Ctrl+Z${NC}     - Suspend foreground process"
    echo -e "  ${GREEN}wait${NC}       - Wait for all background jobs"
    echo -e "  ${GREEN}wait PID${NC}   - Wait for specific process"
    echo
    echo -e "${YELLOW}► Exercise: Job control demo${NC}"
    echo
    sleep 10 &
    local pid1=$!
    sleep 10 &
    local pid2=$!
    echo "Started two background jobs: $pid1, $pid2"
    echo
    echo -e "${DIM}Command:${NC} jobs"
    jobs 2>/dev/null || echo "(jobs requires interactive shell)"
    echo
    kill $pid1 $pid2 2>/dev/null || true
    echo "Cleaned up background jobs."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 5: systemd
# -----------------------------------------------------------------------------
step_systemd() {
    print_header

    echo -e "${BOLD}systemd: Production Supervision${NC}"
    echo
    echo "systemd is the standard Linux init system and supervisor:"
    echo
    echo -e "${DIM}/etc/systemd/system/myagent.service${NC}"
    cat << 'EOF'
  [Unit]
  Description=My Agent
  After=network.target

  [Service]
  Type=simple
  ExecStart=/usr/local/bin/myagent
  Restart=on-failure
  RestartSec=5
  Environment=API_KEY=xxx
  WorkingDirectory=/opt/myagent

  [Install]
  WantedBy=multi-user.target
EOF
    echo
    echo -e "${YELLOW}Common commands:${NC}"
    echo
    echo "  systemctl start myagent    # Start"
    echo "  systemctl stop myagent     # Stop gracefully"
    echo "  systemctl restart myagent  # Restart"
    echo "  systemctl status myagent   # Show status"
    echo "  journalctl -u myagent -f   # Follow logs"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 6: Process groups
# -----------------------------------------------------------------------------
step_process_groups() {
    print_header

    echo -e "${BOLD}Process Groups and Sessions${NC}"
    echo
    echo "Processes are organized into groups and sessions:"
    echo
    echo -e "  ${GREEN}Process Group${NC} - Processes that receive signals together"
    echo -e "  ${GREEN}Session${NC}       - Collection of process groups"
    echo -e "  ${GREEN}Session Leader${NC} - Usually the login shell"
    echo
    echo -e "${YELLOW}► See this script's group:${NC}"
    echo
    echo -e "${DIM}Command:${NC} ps -o pid,pgid,sid,cmd -p \$\$"
    echo
    ps -o pid,pgid,sid,cmd -p $$ 2>/dev/null || ps -p $$
    echo
    echo -e "${YELLOW}Why groups matter:${NC}"
    echo
    echo "  # Kill entire group (note the minus sign)"
    echo "  kill -TERM -\$PGID"
    echo
    echo "This kills the orchestrator AND all its subagents."
    echo "Essential for clean shutdown of agent trees."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 7: Observing supervision
# -----------------------------------------------------------------------------
step_observing() {
    print_header

    echo -e "${BOLD}Observing Supervision${NC}"
    echo
    echo "Watch the supervisor-worker relationship:"
    echo
    echo -e "${YELLOW}► See process parent relationships:${NC}"
    echo
    echo -e "${DIM}Command:${NC} ps -ef --forest | head -20"
    echo
    ps -ef --forest 2>/dev/null | head -15 || ps -ef | head -15
    echo "..."
    echo
    echo -e "${YELLOW}► Track restarts in logs:${NC}"
    echo
    echo "  journalctl -u myagent | grep -i restart"
    echo
    echo -e "${YELLOW}► Monitor with watch:${NC}"
    echo
    echo "  watch -n1 'ps aux | grep [m]yagent'"
    echo
    echo "The forest view shows who supervises whom."
    echo "This is the agent hierarchy made visible."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 8: Summary
# -----------------------------------------------------------------------------
step_summary() {
    print_header

    echo -e "${BOLD}Summary: Process Supervision${NC}"
    echo
    echo -e "${GREEN}✓${NC} Supervisors restart crashed processes"
    echo -e "${GREEN}✓${NC} Graceful shutdown forwards signals to children"
    echo -e "${GREEN}✓${NC} Backoff prevents restart storms"
    echo -e "${GREEN}✓${NC} systemd handles production supervision"
    echo -e "${GREEN}✓${NC} Process groups enable tree-wide signals"
    echo
    echo -e "${CYAN}Supervision toolkit:${NC}"
    echo
    echo "  while true; do cmd; done    # Simple restart"
    echo "  trap 'kill \$PID' TERM       # Forward signals"
    echo "  wait \$PID                   # Wait for child"
    echo "  kill -TERM -\$PGID           # Kill group"
    echo "  systemctl status service    # Check systemd"
    echo "  ps --forest                 # See hierarchy"
    echo
    echo -e "${YELLOW}Agent architecture insight:${NC}"
    echo "  - Agents ARE supervised processes"
    echo "  - Subagents ARE child processes"
    echo "  - Crash recovery = restart policy"
    echo "  - Clean shutdown = signal handling"
    echo
    echo -e "${BOLD}Phase 1 Complete!${NC}"
    echo
    echo "You now understand the Unix primitives underlying"
    echo "all agent systems. Next: mapping these to Elixir/BEAM."

    print_nav
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------
main() {
    while true; do
        case $STEP in
            0) step_intro ;;
            1) step_restart_loop ;;
            2) step_graceful ;;
            3) step_backoff ;;
            4) step_job_control ;;
            5) step_systemd ;;
            6) step_process_groups ;;
            7) step_observing ;;
            *) step_summary ;;
        esac
        wait_for_key
    done
}

main
