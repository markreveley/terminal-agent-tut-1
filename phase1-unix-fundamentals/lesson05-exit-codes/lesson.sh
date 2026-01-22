#!/bin/bash
#
# Lesson 05: Exit Codes
# ======================
# Exit codes are Unix's success/failure protocol.
# They enable conditional execution and error handling.
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
    echo -e "${BOLD}  LESSON 05: Exit Codes${NC}"
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

    echo -e "${BOLD}What are Exit Codes?${NC}"
    echo
    echo "Every Unix command returns an exit code (0-255):"
    echo
    echo -e "  ${GREEN}0${NC}   = Success"
    echo -e "  ${RED}1-255${NC} = Failure (with different meanings)"
    echo
    echo "Access the last exit code with: \$?"
    echo
    echo -e "${YELLOW}► Exercise: See exit codes${NC}"
    echo
    echo -e "${DIM}Command:${NC} true; echo \$?"
    true
    echo -e "${CYAN}Result:${NC} $?"
    echo
    echo -e "${DIM}Command:${NC} false; echo \$?"
    false || true  # Don't exit the script
    echo -e "${CYAN}Result:${NC} 1"
    echo
    echo -e "${YELLOW}Why this matters for agents:${NC}"
    echo "Exit codes are the contract between tools and orchestrators."
    echo "An agent must check: did the tool succeed?"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 1: Common exit codes
# -----------------------------------------------------------------------------
step_common_codes() {
    print_header

    echo -e "${BOLD}Common Exit Codes${NC}"
    echo
    echo "While 1-255 can mean anything, conventions exist:"
    echo
    echo -e "  ${GREEN}0${NC}   - Success"
    echo -e "  ${RED}1${NC}   - General error"
    echo -e "  ${RED}2${NC}   - Misuse of command (bad args)"
    echo -e "  ${RED}126${NC} - Command found but not executable"
    echo -e "  ${RED}127${NC} - Command not found"
    echo -e "  ${RED}128${NC} - Invalid exit code"
    echo -e "  ${RED}128+N${NC} - Killed by signal N (e.g., 137 = SIGKILL)"
    echo -e "  ${RED}130${NC} - Terminated by Ctrl+C (128+2)"
    echo
    echo -e "${YELLOW}► Exercise: See signal-based exit codes${NC}"
    echo
    echo -e "${DIM}Command:${NC} sleep 10 & kill -9 \$!; wait \$!; echo \$?"
    echo
    sleep 10 &
    local pid=$!
    sleep 0.1
    kill -9 $pid 2>/dev/null
    wait $pid 2>/dev/null || true
    echo -e "${CYAN}Result:${NC} 137 (128 + 9 = SIGKILL)"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 2: Conditional execution
# -----------------------------------------------------------------------------
step_conditional() {
    print_header

    echo -e "${BOLD}Conditional Execution${NC}"
    echo
    echo "Exit codes control program flow:"
    echo
    echo -e "  ${GREEN}cmd1 && cmd2${NC}  - Run cmd2 only if cmd1 succeeds"
    echo -e "  ${GREEN}cmd1 || cmd2${NC}  - Run cmd2 only if cmd1 fails"
    echo -e "  ${GREEN}cmd1 ; cmd2${NC}   - Run both regardless"
    echo
    echo -e "${YELLOW}► Exercise: Conditional chains${NC}"
    echo
    echo -e "${DIM}Command:${NC} true && echo 'Success!'"
    echo -e "${CYAN}Result:${NC} $(true && echo 'Success!')"
    echo
    echo -e "${DIM}Command:${NC} false && echo 'Success!'"
    echo -e "${CYAN}Result:${NC} $(false && echo 'Success!' || echo '(nothing printed)')"
    echo
    echo -e "${DIM}Command:${NC} false || echo 'Failed, running fallback'"
    echo -e "${CYAN}Result:${NC} $(false || echo 'Failed, running fallback')"
    echo
    echo -e "${GREEN}Pattern: Try with fallback${NC}"
    echo "  git pull || git fetch origin main"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 3: set -e
# -----------------------------------------------------------------------------
step_set_e() {
    print_header

    echo -e "${BOLD}set -e: Exit on Error${NC}"
    echo
    echo "'set -e' makes the script exit on any error:"
    echo
    echo -e "${CYAN}Without set -e:${NC}"
    echo "  false"
    echo "  echo 'Still running!'  # This runs"
    echo
    echo -e "${CYAN}With set -e:${NC}"
    echo "  set -e"
    echo "  false"
    echo "  echo 'Never reached'   # Script exited"
    echo
    echo -e "${YELLOW}Best practices:${NC}"
    echo
    echo -e "  ${GREEN}set -e${NC}          - Exit on error"
    echo -e "  ${GREEN}set -u${NC}          - Error on undefined variable"
    echo -e "  ${GREEN}set -o pipefail${NC} - Catch errors in pipelines"
    echo
    echo -e "${DIM}Combine them:${NC} set -euo pipefail"
    echo
    echo -e "${YELLOW}This script uses set -e!${NC}"
    echo "That's why we write 'false || true' in examples -"
    echo "to prevent false from killing the lesson."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 4: Custom exit codes
# -----------------------------------------------------------------------------
step_custom_exit() {
    print_header

    echo -e "${BOLD}Custom Exit Codes${NC}"
    echo
    echo "Use 'exit N' to return a specific code:"
    echo
    cat << 'EOF'
  #!/bin/bash
  # validate.sh - Exit with specific codes

  if [[ ! -f "$1" ]]; then
      echo "Error: File not found" >&2
      exit 2
  fi

  if [[ ! -r "$1" ]]; then
      echo "Error: File not readable" >&2
      exit 3
  fi

  echo "File OK"
  exit 0
EOF
    echo
    echo -e "${YELLOW}► Exercise: Check exit code meaning${NC}"
    echo
    echo -e "${DIM}Command:${NC} (exit 42); echo \"Exit code: \$?\""
    echo
    (exit 42) || true
    echo -e "${CYAN}Result:${NC} Exit code: 42"
    echo
    echo -e "${GREEN}Document your exit codes!${NC}"
    echo "Tools should have predictable failure modes."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 5: Error handling patterns
# -----------------------------------------------------------------------------
step_error_patterns() {
    print_header

    echo -e "${BOLD}Error Handling Patterns${NC}"
    echo
    echo -e "${CYAN}Pattern 1: Check and handle${NC}"
    echo "  if ! some_command; then"
    echo "      echo 'Failed!' >&2"
    echo "      exit 1"
    echo "  fi"
    echo
    echo -e "${CYAN}Pattern 2: Fallback chain${NC}"
    echo "  primary_method || fallback_method || panic"
    echo
    echo -e "${CYAN}Pattern 3: Capture and inspect${NC}"
    echo "  output=\$(some_command 2>&1)"
    echo "  status=\$?"
    echo "  if [[ \$status -ne 0 ]]; then"
    echo "      echo \"Failed with: \$output\" >&2"
    echo "  fi"
    echo
    echo -e "${CYAN}Pattern 4: Trap ERR${NC}"
    echo "  trap 'echo \"Error on line \$LINENO\"' ERR"
    echo
    echo -e "${YELLOW}For agents:${NC}"
    echo "Every tool call should capture both output AND exit code."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 6: Testing exit codes
# -----------------------------------------------------------------------------
step_testing() {
    print_header

    echo -e "${BOLD}Testing with Exit Codes${NC}"
    echo
    echo "Exit codes make testing simple:"
    echo
    echo -e "${CYAN}Test script:${NC}"
    echo "  #!/bin/bash"
    echo "  set -e"
    echo
    echo "  # Test 1: Check output"
    echo "  [[ \$(echo hello) == 'hello' ]]"
    echo
    echo "  # Test 2: Check file exists"
    echo "  [[ -f /etc/passwd ]]"
    echo
    echo "  # Test 3: Check exit code"
    echo "  grep -q root /etc/passwd"
    echo
    echo "  echo 'All tests passed!'"
    echo
    echo -e "${YELLOW}► Exercise: Test bracket expressions${NC}"
    echo
    echo -e "${DIM}Command:${NC} [[ 1 -eq 1 ]]; echo \$?"
    [[ 1 -eq 1 ]]
    echo -e "${CYAN}Result:${NC} $?"
    echo
    echo -e "${DIM}Command:${NC} [[ 1 -eq 2 ]]; echo \$?"
    [[ 1 -eq 2 ]] || true
    echo -e "${CYAN}Result:${NC} 1"
    echo
    echo "[[ ]] returns 0 (true) or 1 (false)"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 7: Summary
# -----------------------------------------------------------------------------
step_summary() {
    print_header

    echo -e "${BOLD}Summary: Exit Codes${NC}"
    echo
    echo -e "${GREEN}✓${NC} Exit code 0 = success, 1-255 = failure"
    echo -e "${GREEN}✓${NC} \$? contains the last exit code"
    echo -e "${GREEN}✓${NC} && runs on success, || runs on failure"
    echo -e "${GREEN}✓${NC} set -e exits script on any error"
    echo -e "${GREEN}✓${NC} 128+N indicates death by signal N"
    echo
    echo -e "${CYAN}Exit code toolkit:${NC}"
    echo
    echo "  cmd; echo \$?            # Check exit code"
    echo "  cmd && on_success        # Conditional success"
    echo "  cmd || on_failure        # Conditional failure"
    echo "  set -euo pipefail        # Strict error handling"
    echo "  exit N                   # Custom exit code"
    echo "  trap 'cleanup' ERR       # Handle errors"
    echo
    echo -e "${YELLOW}Agent relevance:${NC}"
    echo "  - Tool success/failure = exit code"
    echo "  - Agent must check every tool result"
    echo "  - Error handling = || chains or traps"
    echo "  - Tests are just exit code checks"
    echo
    echo -e "${YELLOW}Next lesson:${NC} Environment and State"

    print_nav
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------
main() {
    while true; do
        case $STEP in
            0) step_intro ;;
            1) step_common_codes ;;
            2) step_conditional ;;
            3) step_set_e ;;
            4) step_custom_exit ;;
            5) step_error_patterns ;;
            6) step_testing ;;
            *) step_summary ;;
        esac
        wait_for_key
    done
}

main
