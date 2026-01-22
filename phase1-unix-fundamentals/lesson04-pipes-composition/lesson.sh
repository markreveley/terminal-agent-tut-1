#!/bin/bash
#
# Lesson 04: Pipes and Composition
# =================================
# Unix philosophy: small tools that do one thing well,
# connected by pipes. This lesson teaches stdin/stdout
# and the art of composition.
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
    echo -e "${BOLD}  LESSON 04: Pipes and Composition${NC}"
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

    echo -e "${BOLD}The Unix Philosophy${NC}"
    echo
    echo "\"Write programs that do one thing and do it well."
    echo " Write programs to work together."
    echo " Write programs to handle text streams.\""
    echo -e "                              ${DIM}— Doug McIlroy${NC}"
    echo
    echo -e "${CYAN}The Three Standard Streams:${NC}"
    echo
    echo -e "  ${GREEN}stdin  (0)${NC} - Input to a program"
    echo -e "  ${GREEN}stdout (1)${NC} - Normal output"
    echo -e "  ${GREEN}stderr (2)${NC} - Error output"
    echo
    echo -e "${YELLOW}Why this matters for agents:${NC}"
    echo "Agents are composed from tools. Each tool reads input,"
    echo "processes it, and produces output. Pipes connect them."
    echo "An agent orchestrating tools IS a pipeline."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 1: The pipe operator
# -----------------------------------------------------------------------------
step_pipe_operator() {
    print_header

    echo -e "${BOLD}The Pipe Operator: |${NC}"
    echo
    echo "The pipe connects stdout of one command to stdin of another:"
    echo
    echo -e "  ${GREEN}command1 | command2 | command3${NC}"
    echo
    echo -e "${YELLOW}► Exercise: Build a pipeline${NC}"
    echo
    echo -e "${DIM}Command:${NC} echo 'hello world' | tr 'a-z' 'A-Z' | rev"
    echo
    echo -e "${CYAN}Result:${NC}"
    echo "hello world" | tr 'a-z' 'A-Z' | rev
    echo
    echo -e "${GREEN}Data flows left to right:${NC}"
    echo "  'hello world' → 'HELLO WORLD' → 'DLROW OLLEH'"
    echo
    echo -e "${YELLOW}► Real-world example:${NC}"
    echo
    echo -e "${DIM}Command:${NC} ps aux | grep bash | grep -v grep | wc -l"
    echo
    echo -e "${CYAN}Result:${NC} $(ps aux | grep bash | grep -v grep | wc -l) bash processes running"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 2: Redirection
# -----------------------------------------------------------------------------
step_redirection() {
    print_header

    echo -e "${BOLD}Redirection: Files as Streams${NC}"
    echo
    echo "Redirect streams to/from files:"
    echo
    echo -e "  ${GREEN}cmd > file${NC}   - stdout to file (overwrite)"
    echo -e "  ${GREEN}cmd >> file${NC}  - stdout to file (append)"
    echo -e "  ${GREEN}cmd < file${NC}   - file to stdin"
    echo -e "  ${GREEN}cmd 2> file${NC}  - stderr to file"
    echo -e "  ${GREEN}cmd &> file${NC}  - both stdout and stderr to file"
    echo
    echo -e "${YELLOW}► Exercise: Capture and separate streams${NC}"
    echo
    local tmpdir=$(mktemp -d)
    echo -e "${DIM}Command:${NC} ls /etc /nonexistent 2>err.txt 1>out.txt"
    echo
    ls /etc /nonexistent 2>"$tmpdir/err.txt" 1>"$tmpdir/out.txt" || true
    echo -e "${CYAN}stdout (out.txt):${NC}"
    head -3 "$tmpdir/out.txt"
    echo "  ..."
    echo
    echo -e "${CYAN}stderr (err.txt):${NC}"
    cat "$tmpdir/err.txt"
    rm -rf "$tmpdir"
    echo
    echo -e "${GREEN}Separating streams lets you handle errors differently.${NC}"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 3: tee - splitting streams
# -----------------------------------------------------------------------------
step_tee() {
    print_header

    echo -e "${BOLD}tee: The Stream Splitter${NC}"
    echo
    echo "'tee' copies stdin to both stdout AND a file:"
    echo
    echo -e "  ${GREEN}cmd | tee file${NC}     - Save and continue pipeline"
    echo -e "  ${GREEN}cmd | tee -a file${NC}  - Append instead of overwrite"
    echo
    echo -e "${YELLOW}► Exercise: Log while processing${NC}"
    echo
    local tmpfile=$(mktemp)
    echo -e "${DIM}Command:${NC} echo 'processing data' | tee log.txt | tr 'a-z' 'A-Z'"
    echo
    echo -e "${CYAN}Output:${NC}"
    echo "processing data" | tee "$tmpfile" | tr 'a-z' 'A-Z'
    echo
    echo -e "${CYAN}log.txt contains:${NC}"
    cat "$tmpfile"
    rm -f "$tmpfile"
    echo
    echo -e "${YELLOW}Agent pattern:${NC}"
    echo "  # Log every API response while processing"
    echo "  curl api.example.com | tee responses.log | jq '.result'"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 4: Process substitution
# -----------------------------------------------------------------------------
step_process_sub() {
    print_header

    echo -e "${BOLD}Process Substitution${NC}"
    echo
    echo "Treat command output as a file:"
    echo
    echo -e "  ${GREEN}<(cmd)${NC}  - Command output as readable file"
    echo -e "  ${GREEN}>(cmd)${NC}  - Writable file that feeds command"
    echo
    echo -e "${YELLOW}► Exercise: Compare two command outputs${NC}"
    echo
    echo -e "${DIM}Command:${NC} diff <(ls /bin | head -5) <(ls /usr/bin | head -5)"
    echo
    echo -e "${CYAN}Result:${NC}"
    diff <(ls /bin | head -5) <(ls /usr/bin | head -5) || true
    echo
    echo -e "${YELLOW}► What's happening under the hood:${NC}"
    echo
    echo -e "${DIM}Command:${NC} echo <(ls)"
    echo
    echo -e "${CYAN}Result:${NC} $(echo <(ls))"
    echo
    echo "It creates a special file in /dev/fd/ that"
    echo "contains the command's output."

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 5: Named pipes (FIFOs)
# -----------------------------------------------------------------------------
step_fifo() {
    print_header

    echo -e "${BOLD}Named Pipes (FIFOs)${NC}"
    echo
    echo "A named pipe is a pipe that exists as a file:"
    echo
    echo -e "  ${GREEN}mkfifo mypipe${NC}      - Create named pipe"
    echo -e "  ${GREEN}cmd > mypipe &${NC}     - Write to pipe (background)"
    echo -e "  ${GREEN}cmd < mypipe${NC}       - Read from pipe"
    echo
    echo -e "${YELLOW}► Exercise: Create a FIFO${NC}"
    echo
    local tmpdir=$(mktemp -d)
    local fifo="$tmpdir/mypipe"
    mkfifo "$fifo"
    echo -e "${DIM}Command:${NC} mkfifo mypipe && ls -la mypipe"
    echo
    echo -e "${CYAN}Result:${NC}"
    ls -la "$fifo"
    echo
    echo -e "${GREEN}Note the 'p' at the start - it's a pipe, not a regular file.${NC}"
    echo
    echo -e "${YELLOW}Agent use case:${NC}"
    echo "FIFOs let separate processes communicate."
    echo "An orchestrator can write commands to a FIFO,"
    echo "and a worker process reads and executes them."
    rm -rf "$tmpdir"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 6: Pipeline exit codes
# -----------------------------------------------------------------------------
step_pipeline_exit() {
    print_header

    echo -e "${BOLD}Pipeline Exit Codes${NC}"
    echo
    echo "By default, a pipeline's exit code is the LAST command's:"
    echo
    echo -e "${YELLOW}► Exercise: See pipeline exit behavior${NC}"
    echo
    echo -e "${DIM}Command:${NC} false | true; echo \$?"
    echo
    false | true
    echo -e "${CYAN}Result:${NC} $?"
    echo
    echo "The pipeline 'succeeded' even though false failed!"
    echo
    echo -e "${GREEN}Fix with pipefail:${NC}"
    echo
    echo -e "${DIM}Command:${NC} set -o pipefail; false | true; echo \$?"
    echo
    set -o pipefail
    false | true || true  # Don't exit the lesson
    local code=$?
    set +o pipefail
    echo -e "${CYAN}Result:${NC} $code"
    echo
    echo "With pipefail, any failure in the pipeline is caught."
    echo
    echo -e "${YELLOW}For agents: Always use ${GREEN}set -o pipefail${YELLOW} in scripts!${NC}"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 7: Composition patterns
# -----------------------------------------------------------------------------
step_composition() {
    print_header

    echo -e "${BOLD}Composition Patterns${NC}"
    echo
    echo -e "${CYAN}Pattern 1: Filter Chain${NC}"
    echo "  cat data.txt | grep 'error' | sort | uniq -c | sort -rn"
    echo
    echo -e "${CYAN}Pattern 2: Transform Pipeline${NC}"
    echo "  curl api.com | jq '.items[]' | while read item; do"
    echo "    process \"\$item\""
    echo "  done"
    echo
    echo -e "${CYAN}Pattern 3: Parallel Processing${NC}"
    echo "  cat urls.txt | xargs -P4 -I{} curl {}"
    echo
    echo -e "${CYAN}Pattern 4: Tee for Logging${NC}"
    echo "  generate_response | tee -a conversation.log | send_to_user"
    echo
    echo -e "${YELLOW}Agent as Pipeline:${NC}"
    echo
    echo "  read_context | \\"
    echo "    call_llm | \\"
    echo "    parse_response | \\"
    echo "    execute_tool | \\"
    echo "    update_context"

    print_nav
}

# -----------------------------------------------------------------------------
# STEP 8: Summary
# -----------------------------------------------------------------------------
step_summary() {
    print_header

    echo -e "${BOLD}Summary: Pipes and Composition${NC}"
    echo
    echo -e "${GREEN}✓${NC} stdin/stdout/stderr are the standard streams"
    echo -e "${GREEN}✓${NC} | connects stdout to stdin"
    echo -e "${GREEN}✓${NC} > >> < redirect to/from files"
    echo -e "${GREEN}✓${NC} tee splits streams for logging"
    echo -e "${GREEN}✓${NC} <() process substitution creates virtual files"
    echo -e "${GREEN}✓${NC} mkfifo creates named pipes for IPC"
    echo
    echo -e "${CYAN}Composition toolkit:${NC}"
    echo
    echo "  cmd1 | cmd2 | cmd3        # Pipeline"
    echo "  cmd > out.txt 2> err.txt  # Separate streams"
    echo "  cmd | tee log.txt | next  # Log and continue"
    echo "  diff <(cmd1) <(cmd2)      # Compare outputs"
    echo "  set -o pipefail           # Catch pipeline errors"
    echo
    echo -e "${YELLOW}Agent relevance:${NC}"
    echo "  - Tools are commands that read stdin, write stdout"
    echo "  - Agent orchestration IS pipeline composition"
    echo "  - Logging = tee into files"
    echo "  - Tool results flow through pipes"
    echo
    echo -e "${YELLOW}Next lesson:${NC} Exit Codes"

    print_nav
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------
main() {
    while true; do
        case $STEP in
            0) step_intro ;;
            1) step_pipe_operator ;;
            2) step_redirection ;;
            3) step_tee ;;
            4) step_process_sub ;;
            5) step_fifo ;;
            6) step_pipeline_exit ;;
            7) step_composition ;;
            *) step_summary ;;
        esac
        wait_for_key
    done
}

main
