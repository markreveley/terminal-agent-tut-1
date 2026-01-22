#!/bin/bash
#
# Lesson 01: Everything is a File
# ================================
# In Unix, almost everything is represented as a file.
# This lesson teaches you to observe this fundamental abstraction.
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
NC='\033[0m' # No Color

# State
STEP=0
TOTAL_STEPS=6

print_header() {
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  LESSON 01: Everything is a File${NC}"
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
        n|N|'')
            [[ $STEP -lt $((TOTAL_STEPS-1)) ]] && ((STEP++))
            ;;
        p|P)
            [[ $STEP -gt 0 ]] && ((STEP--))
            ;;
        q|Q)
            echo
            echo -e "${GREEN}Lesson complete. Keep observing!${NC}"
            exit 0
            ;;
    esac
}

# -----------------------------------------------------------------------------
# STEP 0: Introduction
# -----------------------------------------------------------------------------
step_intro() {
    print_header

    echo -e "${BOLD}The Unix Philosophy: Everything is a File${NC}"
    echo
    echo "In Unix, almost everything is represented as a file:"
    echo
    echo -e "  ${CYAN}•${NC} Regular files (text, binaries)"
    echo -e "  ${CYAN}•${NC} Directories (files that list other files)"
    echo -e "  ${CYAN}•${NC} Devices (/dev/null, /dev/tty)"
    echo -e "  ${CYAN}•${NC} Process information (/proc)"
    echo -e "  ${CYAN}•${NC} Network sockets"
    echo -e "  ${CYAN}•${NC} Pipes between processes"
    echo
    echo -e "${YELLOW}Why this matters for agents:${NC}"
    echo "If everything is a file, then everything can be inspected with"
    echo "the same tools: cat, ls, head, tail, grep."
    echo
    echo -e "${DIM}This is the foundation of Unix observability.${NC}"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 1: File Descriptors
# -----------------------------------------------------------------------------
step_file_descriptors() {
    print_header

    echo -e "${BOLD}File Descriptors: How Processes Talk${NC}"
    echo
    echo "Every process has at least three open files:"
    echo
    echo -e "  ${GREEN}0${NC} = stdin  (standard input)"
    echo -e "  ${GREEN}1${NC} = stdout (standard output)"
    echo -e "  ${GREEN}2${NC} = stderr (standard error)"
    echo
    echo -e "${YELLOW}► Exercise: See this script's file descriptors${NC}"
    echo
    echo -e "${DIM}Command:${NC} ls -la /proc/$$/fd"
    echo
    echo -e "${CYAN}Result:${NC}"
    ls -la /proc/$$/fd 2>/dev/null | head -10
    echo
    echo -e "${GREEN}Observation:${NC} Notice 0, 1, 2 point to your terminal (/dev/pts/X)."
    echo "This is how the script reads your input and writes output."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 2: /proc filesystem
# -----------------------------------------------------------------------------
step_proc() {
    print_header

    echo -e "${BOLD}/proc: Processes as Files${NC}"
    echo
    echo "/proc is a virtual filesystem exposing kernel and process info."
    echo "Every running process has a directory: /proc/PID/"
    echo
    echo -e "${YELLOW}► Exercise: Inspect this script's process${NC}"
    echo
    echo -e "${DIM}This script's PID:${NC} $$"
    echo
    echo -e "${DIM}Command:${NC} ls /proc/$$/"
    echo
    echo -e "${CYAN}Key files in /proc/$$/:${NC}"
    echo
    echo -e "  ${GREEN}cmdline${NC}  - Command that started this process"
    echo -e "  ${GREEN}environ${NC}  - Environment variables"
    echo -e "  ${GREEN}fd/${NC}      - Open file descriptors"
    echo -e "  ${GREEN}status${NC}   - Process status (state, memory, etc.)"
    echo -e "  ${GREEN}cwd${NC}      - Current working directory (symlink)"
    echo
    echo -e "${YELLOW}► Try it: What command started this script?${NC}"
    echo
    echo -e "${DIM}Command:${NC} cat /proc/$$/cmdline | tr '\\0' ' '"
    echo
    echo -e "${CYAN}Result:${NC} $(cat /proc/$$/cmdline | tr '\0' ' ')"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 3: /dev devices
# -----------------------------------------------------------------------------
step_dev() {
    print_header

    echo -e "${BOLD}/dev: Devices as Files${NC}"
    echo
    echo "Hardware and virtual devices are exposed as files in /dev."
    echo
    echo -e "${CYAN}Key devices:${NC}"
    echo
    echo -e "  ${GREEN}/dev/null${NC}   - Black hole (discards all input)"
    echo -e "  ${GREEN}/dev/zero${NC}   - Infinite stream of zero bytes"
    echo -e "  ${GREEN}/dev/random${NC} - Random bytes (blocking)"
    echo -e "  ${GREEN}/dev/tty${NC}    - Current terminal"
    echo -e "  ${GREEN}/dev/stdin${NC}  - Symlink to fd 0"
    echo
    echo -e "${YELLOW}► Exercise: Write to /dev/null${NC}"
    echo
    echo -e "${DIM}Command:${NC} echo 'This disappears' > /dev/null && echo 'Nothing returned'"
    echo
    echo -e "${CYAN}Result:${NC} $(echo 'This disappears' > /dev/null && echo 'Nothing returned')"
    echo
    echo -e "${YELLOW}► Exercise: Read random bytes${NC}"
    echo
    echo -e "${DIM}Command:${NC} head -c 16 /dev/urandom | xxd"
    echo
    echo -e "${CYAN}Result:${NC}"
    head -c 16 /dev/urandom | xxd

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 4: Observing another process
# -----------------------------------------------------------------------------
step_observe_process() {
    print_header

    echo -e "${BOLD}Observing Other Processes${NC}"
    echo
    echo "Since everything is a file, you can inspect ANY process"
    echo "(that you have permission to access)."
    echo
    echo -e "${YELLOW}► Exercise: Find and inspect a process${NC}"
    echo

    # Find a simple process to inspect
    local target_pid=$(pgrep -o bash 2>/dev/null | head -1)
    if [[ -z "$target_pid" ]]; then
        target_pid=1
    fi

    echo -e "${DIM}Let's inspect PID $target_pid:${NC}"
    echo
    echo -e "${DIM}Command:${NC} cat /proc/$target_pid/status | head -10"
    echo
    echo -e "${CYAN}Result:${NC}"
    cat /proc/$target_pid/status 2>/dev/null | head -10 || echo "(Permission denied or process doesn't exist)"
    echo
    echo -e "${GREEN}Key fields:${NC}"
    echo "  Name   - Process name"
    echo "  State  - Running (R), Sleeping (S), Zombie (Z), etc."
    echo "  Pid    - Process ID"
    echo "  PPid   - Parent process ID"
    echo "  Uid    - User ID running the process"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 5: Practical application
# -----------------------------------------------------------------------------
step_practical() {
    print_header

    echo -e "${BOLD}Practical Application: Agent Observability${NC}"
    echo
    echo "When an agent runs, it's just a process with files."
    echo "You can always ask:"
    echo
    echo -e "  ${CYAN}•${NC} What processes exist?     ${DIM}→ ps aux${NC}"
    echo -e "  ${CYAN}•${NC} What files are open?      ${DIM}→ ls /proc/PID/fd${NC}"
    echo -e "  ${CYAN}•${NC} What's the current dir?   ${DIM}→ readlink /proc/PID/cwd${NC}"
    echo -e "  ${CYAN}•${NC} What environment?         ${DIM}→ cat /proc/PID/environ${NC}"
    echo -e "  ${CYAN}•${NC} What's the memory usage?  ${DIM}→ cat /proc/PID/status${NC}"
    echo
    echo -e "${YELLOW}The agent cannot hide from /proc.${NC}"
    echo
    echo "This is why Unix provides observability by default."
    echo "An agent that writes files, spawns processes, or opens"
    echo "network connections leaves traces you can inspect."
    echo
    echo -e "${GREEN}Exercise for later:${NC}"
    echo "Run any long-running process in the background, then"
    echo "explore its /proc/PID/ directory while it runs."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 6: Summary
# -----------------------------------------------------------------------------
step_summary() {
    print_header

    echo -e "${BOLD}Summary: Everything is a File${NC}"
    echo
    echo -e "${GREEN}✓${NC} File descriptors (0, 1, 2) connect processes to I/O"
    echo -e "${GREEN}✓${NC} /proc exposes process internals as readable files"
    echo -e "${GREEN}✓${NC} /dev exposes devices as files you can read/write"
    echo -e "${GREEN}✓${NC} Any process can be inspected via /proc/PID/"
    echo
    echo -e "${CYAN}Observation toolkit from this lesson:${NC}"
    echo
    echo "  ls -la /proc/\$PID/fd      # Open file descriptors"
    echo "  cat /proc/\$PID/cmdline    # Command line"
    echo "  cat /proc/\$PID/status     # Process status"
    echo "  cat /proc/\$PID/environ    # Environment variables"
    echo "  readlink /proc/\$PID/cwd   # Current directory"
    echo
    echo -e "${YELLOW}Next lesson:${NC} Processes (fork, exec, and process trees)"
    echo
    echo -e "${DIM}Press 'q' to exit, or 'p' to review previous steps.${NC}"

    print_nav
}

# -----------------------------------------------------------------------------
# MAIN LOOP
# -----------------------------------------------------------------------------
main() {
    while true; do
        case $STEP in
            0) step_intro ;;
            1) step_file_descriptors ;;
            2) step_proc ;;
            3) step_dev ;;
            4) step_observe_process ;;
            5) step_practical ;;
            *) step_summary ;;
        esac
        wait_for_key
    done
}

main
