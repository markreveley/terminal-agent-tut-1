#!/bin/bash
#
# Lesson 03: Signals
# ==================
# Signals are the primary mechanism for inter-process communication
# and process control in Unix. This lesson teaches you to send,
# receive, and handle signals.
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
    echo -e "${BOLD}  LESSON 03: Signals${NC}"
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

    echo -e "${BOLD}What are Signals?${NC}"
    echo
    echo "Signals are software interrupts sent to processes."
    echo "They're how Unix processes communicate asynchronously."
    echo
    echo -e "  ${CYAN}•${NC} Signals notify processes of events"
    echo -e "  ${CYAN}•${NC} Processes can catch, ignore, or die from signals"
    echo -e "  ${CYAN}•${NC} Some signals cannot be caught (SIGKILL, SIGSTOP)"
    echo -e "  ${CYAN}•${NC} Signals enable graceful shutdown and restart"
    echo
    echo -e "${YELLOW}Why this matters for agents:${NC}"
    echo "Signals control agent lifecycle. When you Ctrl+C an agent,"
    echo "that's SIGINT. When a parent agent terminates a child,"
    echo "that's SIGTERM. Understanding signals = understanding"
    echo "how agents start, stop, and communicate."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 1: Common signals
# -----------------------------------------------------------------------------
step_common_signals() {
    print_header

    echo -e "${BOLD}Common Signals${NC}"
    echo
    echo "Each signal has a number and a name:"
    echo
    echo -e "  ${GREEN}SIGTERM (15)${NC} - Polite termination request"
    echo -e "                  Process can clean up before exiting"
    echo
    echo -e "  ${GREEN}SIGKILL (9)${NC}  - Forced termination"
    echo -e "                  Cannot be caught or ignored"
    echo
    echo -e "  ${GREEN}SIGINT (2)${NC}   - Interrupt (Ctrl+C)"
    echo -e "                  User requesting termination"
    echo
    echo -e "  ${GREEN}SIGHUP (1)${NC}   - Hangup"
    echo -e "                  Terminal closed or reload config"
    echo
    echo -e "  ${GREEN}SIGUSR1/2${NC}    - User-defined signals"
    echo -e "                  For custom inter-process communication"
    echo
    echo -e "${YELLOW}► Exercise: List all signals${NC}"
    echo
    echo -e "${DIM}Command:${NC} kill -l | head -5"
    echo
    kill -l 2>/dev/null | head -5

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 2: Sending signals
# -----------------------------------------------------------------------------
step_sending() {
    print_header

    echo -e "${BOLD}Sending Signals${NC}"
    echo
    echo "Use 'kill' to send signals (despite the name):"
    echo
    echo -e "  ${GREEN}kill PID${NC}       - Send SIGTERM (default)"
    echo -e "  ${GREEN}kill -9 PID${NC}    - Send SIGKILL"
    echo -e "  ${GREEN}kill -HUP PID${NC}  - Send SIGHUP"
    echo -e "  ${GREEN}kill -0 PID${NC}    - Check if process exists"
    echo
    echo -e "${YELLOW}► Exercise: Send signals to a background process${NC}"
    echo

    # Start a process that ignores SIGTERM for demo
    (trap '' TERM; sleep 60) &
    local pid=$!
    echo "Started: sleep process (PID $pid)"
    echo

    echo "Sending SIGTERM (polite)..."
    kill -TERM $pid 2>/dev/null || true
    sleep 0.2

    if ps -p $pid &>/dev/null; then
        echo -e "${YELLOW}Process still running (it trapped SIGTERM)${NC}"
        echo
        echo "Sending SIGKILL (force)..."
        kill -KILL $pid 2>/dev/null || true
        sleep 0.2

        if ps -p $pid &>/dev/null; then
            echo -e "${RED}Process still running (should not happen)${NC}"
        else
            echo -e "${GREEN}Process terminated by SIGKILL${NC}"
        fi
    else
        echo -e "${GREEN}Process terminated by SIGTERM${NC}"
    fi
    echo
    echo -e "${DIM}SIGKILL cannot be caught - it always works.${NC}"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 3: Trapping signals
# -----------------------------------------------------------------------------
step_trapping() {
    print_header

    echo -e "${BOLD}Trapping Signals: trap${NC}"
    echo
    echo "The 'trap' builtin lets scripts handle signals:"
    echo
    echo -e "${CYAN}Syntax:${NC}"
    echo "  trap 'commands' SIGNAL [SIGNAL ...]"
    echo
    echo -e "${CYAN}Examples:${NC}"
    echo
    echo "  # Run cleanup on exit"
    echo -e "  ${GREEN}trap 'rm -f /tmp/lockfile' EXIT${NC}"
    echo
    echo "  # Ignore SIGINT (Ctrl+C)"
    echo -e "  ${GREEN}trap '' INT${NC}"
    echo
    echo "  # Handle SIGTERM gracefully"
    echo -e "  ${GREEN}trap 'echo Shutting down...; exit 0' TERM${NC}"
    echo
    echo -e "${YELLOW}Special signals:${NC}"
    echo "  EXIT  - Runs when script exits (any reason)"
    echo "  ERR   - Runs when command returns non-zero"
    echo "  DEBUG - Runs before every command"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 4: Trap in action
# -----------------------------------------------------------------------------
step_trap_demo() {
    print_header

    echo -e "${BOLD}Trap in Action${NC}"
    echo
    echo "Let's see trap work in a subshell:"
    echo
    echo -e "${DIM}Script:${NC}"
    echo '  #!/bin/bash'
    echo '  cleanup() { echo "Cleaning up..."; rm -f /tmp/demo.$$; }'
    echo '  trap cleanup EXIT'
    echo '  echo $$ > /tmp/demo.$$'
    echo '  echo "Working... (PID $$)"'
    echo '  sleep 2'
    echo '  echo "Done"'
    echo
    echo -e "${YELLOW}► Running the demo:${NC}"
    echo

    # Run in subshell so we can demonstrate
    (
        cleanup() {
            echo "  Cleaning up temp file..."
            rm -f /tmp/demo.$$ 2>/dev/null
        }
        trap cleanup EXIT
        echo "  Process $$ created /tmp/demo.$$"
        echo $$ > /tmp/demo.$$
        echo "  Working..."
        sleep 1
        echo "  Done - exiting normally"
    )

    echo
    echo -e "${GREEN}The cleanup ran automatically on exit!${NC}"
    echo
    echo "This pattern is essential for agents that need to:"
    echo "  - Release locks"
    echo "  - Close connections"
    echo "  - Save state before terminating"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 5: Signal propagation
# -----------------------------------------------------------------------------
step_propagation() {
    print_header

    echo -e "${BOLD}Signal Propagation${NC}"
    echo
    echo "When you send a signal to a parent process:"
    echo
    echo -e "  ${CYAN}•${NC} Children do NOT automatically receive it"
    echo -e "  ${CYAN}•${NC} Parent must forward signals explicitly"
    echo -e "  ${CYAN}•${NC} Or use process groups for broadcast"
    echo
    echo -e "${YELLOW}Process Groups:${NC}"
    echo
    echo "  # Kill entire process group"
    echo -e "  ${GREEN}kill -TERM -\$PID${NC}  (note the minus sign)"
    echo
    echo "  # Or use pkill with parent PID"
    echo -e "  ${GREEN}pkill -P \$PPID${NC}"
    echo
    echo -e "${YELLOW}Why this matters:${NC}"
    echo
    echo "An agent process that spawns subagents must:"
    echo "  1. Track child PIDs"
    echo "  2. Forward termination signals"
    echo "  3. Wait for children to finish"
    echo "  4. Then exit itself"
    echo
    echo "This is called 'graceful shutdown'."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 6: SIGHUP for reload
# -----------------------------------------------------------------------------
step_sighup() {
    print_header

    echo -e "${BOLD}SIGHUP: Reload Configuration${NC}"
    echo
    echo "SIGHUP traditionally meant 'terminal hung up'."
    echo "Modern daemons repurpose it for config reload:"
    echo
    echo -e "${CYAN}Pattern:${NC}"
    echo
    cat << 'EOF'
  #!/bin/bash
  CONFIG_FILE="/etc/myagent.conf"

  load_config() {
      source "$CONFIG_FILE"
      echo "Config loaded: $SETTING"
  }

  trap load_config HUP

  load_config  # Initial load

  while true; do
      # Main agent loop
      do_work
      sleep 1
  done
EOF
    echo
    echo -e "${YELLOW}Usage:${NC}"
    echo "  # Edit config, then reload without restart:"
    echo -e "  ${GREEN}kill -HUP \$AGENT_PID${NC}"
    echo
    echo "This lets you update agent behavior at runtime"
    echo "without losing state or connections."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 7: Observing signals
# -----------------------------------------------------------------------------
step_observing() {
    print_header

    echo -e "${BOLD}Observing Signals${NC}"
    echo
    echo "You can watch signal delivery with strace:"
    echo
    echo -e "${DIM}Command:${NC} strace -e signal sleep 10 &"
    echo -e "${DIM}         ${NC} kill -TERM \$!"
    echo
    echo -e "${CYAN}What you'd see:${NC}"
    echo "  --- SIGTERM {si_signo=SIGTERM, si_code=SI_USER, ...} ---"
    echo "  +++ killed by SIGTERM +++"
    echo
    echo -e "${YELLOW}► See pending signals for a process:${NC}"
    echo
    echo -e "${DIM}Command:${NC} cat /proc/\$\$/status | grep -i sig"
    echo
    cat /proc/$$/status 2>/dev/null | grep -i sig | head -5
    echo
    echo -e "${GREEN}Fields:${NC}"
    echo "  SigPnd - Pending signals (bitmask)"
    echo "  SigBlk - Blocked signals"
    echo "  SigIgn - Ignored signals"
    echo "  SigCgt - Caught signals (has handler)"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 8: Summary
# -----------------------------------------------------------------------------
step_summary() {
    print_header

    echo -e "${BOLD}Summary: Signals${NC}"
    echo
    echo -e "${GREEN}✓${NC} Signals are asynchronous process notifications"
    echo -e "${GREEN}✓${NC} SIGTERM = polite, SIGKILL = force"
    echo -e "${GREEN}✓${NC} trap catches signals in scripts"
    echo -e "${GREEN}✓${NC} EXIT trap ensures cleanup always runs"
    echo -e "${GREEN}✓${NC} SIGHUP commonly means 'reload config'"
    echo
    echo -e "${CYAN}Signal toolkit:${NC}"
    echo
    echo "  kill -TERM PID         # Polite termination"
    echo "  kill -KILL PID         # Forced termination"
    echo "  kill -HUP PID          # Reload config"
    echo "  kill -0 PID            # Check if alive"
    echo "  trap 'cmd' SIGNAL      # Handle signal"
    echo "  trap 'cmd' EXIT        # Cleanup on exit"
    echo
    echo -e "${YELLOW}Agent relevance:${NC}"
    echo "  - Ctrl+C sends SIGINT to your agent"
    echo "  - Graceful shutdown = trap SIGTERM"
    echo "  - Hot reload = trap SIGHUP"
    echo "  - Kill stuck subagent = SIGKILL"
    echo
    echo -e "${YELLOW}Next lesson:${NC} Pipes and Composition"

    print_nav
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------
main() {
    while true; do
        case $STEP in
            0) step_intro ;;
            1) step_common_signals ;;
            2) step_sending ;;
            3) step_trapping ;;
            4) step_trap_demo ;;
            5) step_propagation ;;
            6) step_sighup ;;
            7) step_observing ;;
            *) step_summary ;;
        esac
        wait_for_key
    done
}

main
