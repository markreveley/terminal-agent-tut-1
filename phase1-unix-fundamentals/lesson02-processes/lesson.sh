#!/bin/bash
#
# Lesson 02: Processes
# =====================
# Processes are the unit of execution in Unix.
# This lesson teaches you to observe, create, and manage them.
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
TOTAL_STEPS=7

print_header() {
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  LESSON 02: Processes${NC}"
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

    echo -e "${BOLD}What is a Process?${NC}"
    echo
    echo "A process is a running instance of a program."
    echo
    echo -e "  ${CYAN}•${NC} Every process has a unique ID (PID)"
    echo -e "  ${CYAN}•${NC} Every process has a parent (PPID)"
    echo -e "  ${CYAN}•${NC} Processes form a tree with PID 1 at the root"
    echo -e "  ${CYAN}•${NC} Processes are isolated from each other"
    echo
    echo -e "${YELLOW}Why this matters for agents:${NC}"
    echo "Agents are processes. Subagents are child processes."
    echo "Understanding process relationships means understanding"
    echo "how agents spawn, communicate, and terminate."
    echo
    echo -e "${DIM}This script is process $$ (PID $$)${NC}"
    echo -e "${DIM}Its parent is process $PPID (PPID $PPID)${NC}"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 1: Viewing processes
# -----------------------------------------------------------------------------
step_viewing() {
    print_header

    echo -e "${BOLD}Viewing Processes: ps${NC}"
    echo
    echo "The 'ps' command shows running processes."
    echo
    echo -e "${YELLOW}► Exercise: See your shell's processes${NC}"
    echo
    echo -e "${DIM}Command:${NC} ps f"
    echo
    echo -e "${CYAN}Result:${NC}"
    ps f 2>/dev/null || ps
    echo
    echo -e "${GREEN}Reading the output:${NC}"
    echo "  PID   - Process ID"
    echo "  TTY   - Terminal attached to"
    echo "  STAT  - State (S=sleeping, R=running)"
    echo "  TIME  - CPU time used"
    echo "  CMD   - Command (tree structure with 'f')"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 2: Process tree
# -----------------------------------------------------------------------------
step_tree() {
    print_header

    echo -e "${BOLD}The Process Tree${NC}"
    echo
    echo "All processes descend from PID 1 (init/systemd)."
    echo
    echo -e "${YELLOW}► Exercise: See the process tree${NC}"
    echo
    echo -e "${DIM}Command:${NC} pstree -p \$\$ | head -20"
    echo
    echo -e "${CYAN}Result:${NC}"
    if command -v pstree &>/dev/null; then
        pstree -p $$ 2>/dev/null | head -20
    else
        echo "(pstree not available, using ps)"
        ps -ef --forest 2>/dev/null | grep -A5 $$ | head -10
    fi
    echo
    echo -e "${GREEN}Observation:${NC}"
    echo "Your shell spawned this script. The script runs inside"
    echo "the shell. When the script exits, control returns to shell."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 3: Creating processes
# -----------------------------------------------------------------------------
step_creating() {
    print_header

    echo -e "${BOLD}Creating Processes${NC}"
    echo
    echo "New processes are created by fork() + exec():"
    echo
    echo -e "  ${GREEN}fork()${NC}  - Clone the current process"
    echo -e "  ${GREEN}exec()${NC}  - Replace the clone with a new program"
    echo
    echo -e "${YELLOW}► Exercise: Spawn a background process${NC}"
    echo
    echo -e "${DIM}Command:${NC} sleep 30 &"
    echo
    sleep 30 &
    local bg_pid=$!
    echo -e "${CYAN}Result:${NC} Started background process with PID $bg_pid"
    echo
    echo -e "${YELLOW}► Observe it:${NC}"
    echo
    echo -e "${DIM}Command:${NC} ps -p $bg_pid"
    echo
    ps -p $bg_pid 2>/dev/null || echo "(Process may have exited)"
    echo
    echo -e "${GREEN}The '&' runs the command in background.${NC}"
    echo "It's still a child of this script."
    echo
    echo -e "${DIM}Cleaning up: kill $bg_pid${NC}"
    kill $bg_pid 2>/dev/null || true

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 4: Parent and child
# -----------------------------------------------------------------------------
step_parent_child() {
    print_header

    echo -e "${BOLD}Parent-Child Relationships${NC}"
    echo
    echo "Every process (except PID 1) has a parent."
    echo "When a parent dies, children are adopted by PID 1."
    echo
    echo -e "${YELLOW}► Exercise: Trace this script's lineage${NC}"
    echo
    echo -e "${CYAN}This script:${NC}"
    echo "  PID:  $$"
    echo "  PPID: $PPID"
    echo
    echo -e "${CYAN}Parent process ($PPID):${NC}"
    if [[ -r /proc/$PPID/comm ]]; then
        echo "  Name: $(cat /proc/$PPID/comm)"
        echo "  Cmd:  $(cat /proc/$PPID/cmdline 2>/dev/null | tr '\0' ' ' | head -c 60)"
    else
        ps -p $PPID -o comm= 2>/dev/null || echo "  (cannot read)"
    fi
    echo
    echo -e "${CYAN}Grandparent:${NC}"
    local gpid=$(ps -o ppid= -p $PPID 2>/dev/null | tr -d ' ')
    if [[ -n "$gpid" && -r /proc/$gpid/comm ]]; then
        echo "  PID:  $gpid"
        echo "  Name: $(cat /proc/$gpid/comm 2>/dev/null)"
    else
        echo "  (cannot determine)"
    fi

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 5: Process states
# -----------------------------------------------------------------------------
step_states() {
    print_header

    echo -e "${BOLD}Process States${NC}"
    echo
    echo "Processes transition between states:"
    echo
    echo -e "  ${GREEN}R${NC} - Running or runnable"
    echo -e "  ${GREEN}S${NC} - Sleeping (waiting for event)"
    echo -e "  ${GREEN}D${NC} - Uninterruptible sleep (usually I/O)"
    echo -e "  ${GREEN}Z${NC} - Zombie (terminated, waiting for parent)"
    echo -e "  ${GREEN}T${NC} - Stopped (by signal)"
    echo
    echo -e "${YELLOW}► Exercise: See process states${NC}"
    echo
    echo -e "${DIM}Command:${NC} ps aux | head -10"
    echo
    echo -e "${CYAN}Result:${NC}"
    ps aux 2>/dev/null | head -10
    echo
    echo -e "${GREEN}Look at the STAT column.${NC}"
    echo "Most processes are 'S' (sleeping) - waiting for work."
    echo
    echo -e "${YELLOW}Why 'Z' (zombie) matters:${NC}"
    echo "If an agent crashes without cleaning up children,"
    echo "those children become zombies until reaped."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 6: Killing processes
# -----------------------------------------------------------------------------
step_killing() {
    print_header

    echo -e "${BOLD}Terminating Processes${NC}"
    echo
    echo "Processes are terminated by signals (covered in Lesson 3)."
    echo
    echo -e "${CYAN}Common termination commands:${NC}"
    echo
    echo -e "  ${GREEN}kill PID${NC}      - Send SIGTERM (graceful)"
    echo -e "  ${GREEN}kill -9 PID${NC}   - Send SIGKILL (force)"
    echo -e "  ${GREEN}pkill name${NC}    - Kill by process name"
    echo -e "  ${GREEN}killall name${NC}  - Kill all with name"
    echo
    echo -e "${YELLOW}► Exercise: Spawn and kill${NC}"
    echo
    sleep 60 &
    local pid=$!
    echo "Started: sleep 60 (PID $pid)"
    echo
    ps -p $pid 2>/dev/null
    echo
    echo "Killing with: kill $pid"
    kill $pid 2>/dev/null
    sleep 0.1
    echo
    if ps -p $pid &>/dev/null; then
        echo -e "${RED}Process still running${NC}"
    else
        echo -e "${GREEN}Process terminated${NC}"
    fi

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 7: Summary
# -----------------------------------------------------------------------------
step_summary() {
    print_header

    echo -e "${BOLD}Summary: Processes${NC}"
    echo
    echo -e "${GREEN}✓${NC} Processes are isolated units of execution"
    echo -e "${GREEN}✓${NC} Every process has PID and PPID"
    echo -e "${GREEN}✓${NC} Processes form a tree (root = PID 1)"
    echo -e "${GREEN}✓${NC} fork() + exec() creates new processes"
    echo -e "${GREEN}✓${NC} States: Running, Sleeping, Zombie, Stopped"
    echo
    echo -e "${CYAN}Observation toolkit from this lesson:${NC}"
    echo
    echo "  ps aux                    # All processes"
    echo "  ps f                      # Forest (tree) view"
    echo "  pstree -p PID             # Process tree from PID"
    echo "  ps -p PID -o ppid=        # Get parent PID"
    echo "  kill PID                  # Terminate gracefully"
    echo "  kill -9 PID               # Terminate forcefully"
    echo
    echo -e "${YELLOW}Agent relevance:${NC}"
    echo "Subagents = child processes. You can:"
    echo "  - See the hierarchy with pstree"
    echo "  - Kill a stuck subagent with kill"
    echo "  - Detect zombies from crashed agents"
    echo
    echo -e "${YELLOW}Next lesson:${NC} Signals (how processes communicate)"

    print_nav
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------
main() {
    while true; do
        case $STEP in
            0) step_intro ;;
            1) step_viewing ;;
            2) step_tree ;;
            3) step_creating ;;
            4) step_parent_child ;;
            5) step_states ;;
            6) step_killing ;;
            *) step_summary ;;
        esac
        wait_for_key
    done
}

main
