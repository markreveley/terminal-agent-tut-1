#!/bin/bash
#
# Agent Architecture Tutorial - Pure Bash Implementation
# ======================================================
# An interactive terminal tutorial using only bash built-ins
# and ANSI escape codes. No external dependencies.
#
# Usage: ./tutorial.sh
#
# Navigation:
#   Arrow keys or n/p - Next/Previous
#   1-5              - Jump to lesson (from home)
#   Enter            - Start from lesson 1
#   q                - Quit
#

set -e

# =============================================================================
# CONFIGURATION & STATE
# =============================================================================

# State variables
SCREEN="home"      # home, lesson1-5, complete
STEP=0             # Current step within lesson
LESSON=1           # Current lesson number
SELECTED_TRACK=""  # unix, sdk, beam

# Terminal dimensions
TERM_COLS=$(tput cols 2>/dev/null || echo 80)
TERM_ROWS=$(tput lines 2>/dev/null || echo 24)

# =============================================================================
# ANSI ESCAPE CODES & COLORS
# =============================================================================

# Reset
RST="\033[0m"

# Text styles
BOLD="\033[1m"
DIM="\033[2m"
ITALIC="\033[3m"

# Foreground colors (256 color mode)
fg() { echo -e "\033[38;5;${1}m"; }

# Colors
C_PRIMARY=$(fg 135)      # Violet
C_SECONDARY=$(fg 44)     # Cyan
C_ACCENT=$(fg 214)       # Amber
C_SUCCESS=$(fg 42)       # Green
C_ERROR=$(fg 196)        # Red
C_WARNING=$(fg 214)      # Amber
C_INFO=$(fg 33)          # Blue
C_TEXT=$(fg 252)         # Light gray
C_MUTED=$(fg 245)        # Muted gray
C_DIM=$(fg 240)          # Dim gray

# Icons
ICON_CHECK="✓"
ICON_CROSS="✗"
ICON_ARROW="→"
ICON_BULLET="•"
ICON_STAR="★"
ICON_ROBOT="🤖"
ICON_SHELL="🐚"
ICON_BEAM="⚗"
ICON_LIGHTNING="⚡"
ICON_CODE="💻"

# Box drawing
BOX_TL="┌"
BOX_TR="┐"
BOX_BL="└"
BOX_BR="┘"
BOX_H="─"
BOX_V="│"

# =============================================================================
# TERMINAL UTILITIES
# =============================================================================

# Clear screen and move cursor to top-left
clear_screen() {
    printf "\033[2J\033[H"
}

# Move cursor to position (row, col) - 1-indexed
move_cursor() {
    printf "\033[%d;%dH" "$1" "$2"
}

# Hide cursor
hide_cursor() {
    printf "\033[?25l"
}

# Show cursor
show_cursor() {
    printf "\033[?25h"
}

# Enter alternate screen buffer
alt_screen_on() {
    printf "\033[?1049h"
}

# Exit alternate screen buffer
alt_screen_off() {
    printf "\033[?1049l"
}

# Print colored text
cprint() {
    local color="$1"
    shift
    printf "${color}%s${RST}" "$*"
}

# Print bold colored text
bprint() {
    local color="$1"
    shift
    printf "${BOLD}${color}%s${RST}" "$*"
}

# Print a horizontal line
hline() {
    local width="${1:-60}"
    local char="${2:-$BOX_H}"
    printf "%${width}s" | tr ' ' "$char"
}

# Repeat a character
repeat_char() {
    local char="$1"
    local count="$2"
    printf "%${count}s" | tr ' ' "$char"
}

# =============================================================================
# UI COMPONENTS
# =============================================================================

# Progress bar: progress_bar <value> <max> <width>
progress_bar() {
    local value="$1"
    local max="${2:-100}"
    local width="${3:-30}"

    local pct=$((value * 100 / max))
    local filled=$((pct * width / 100))
    local empty=$((width - filled))

    local color="$C_SUCCESS"
    [[ $pct -gt 50 ]] && color="$C_WARNING"
    [[ $pct -gt 80 ]] && color="$C_ERROR"

    printf "["
    cprint "$color" "$(repeat_char '█' $filled)"
    cprint "$C_DIM" "$(repeat_char '░' $empty)"
    printf "] %d%%" "$pct"
}

# Lesson header
lesson_header() {
    local num="$1"
    local title="$2"

    bprint "$C_ACCENT" "LESSON $num: "
    bprint "$C_TEXT" "$(echo "$title" | tr '[:lower:]' '[:upper:]')"
    echo
    cprint "$C_DIM" "$(hline 60)"
    echo
}

# Navigation hints
nav_hints() {
    echo
    cprint "$C_DIM" "$(hline 60)"
    echo
    printf "  "
    cprint "$C_SECONDARY" "[←/p]"
    cprint "$C_MUTED" " Previous  "
    cprint "$C_SECONDARY" "[→/n]"
    cprint "$C_MUTED" " Next  "
    cprint "$C_SECONDARY" "[q]"
    cprint "$C_MUTED" " Quit"
    echo
}

# Check item (success)
check_item() {
    local title="$1"
    local desc="$2"

    cprint "$C_SUCCESS" "$ICON_CHECK $title"
    echo
    cprint "$C_MUTED" "     $desc"
    echo
}

# Concept list
concept_list() {
    local title="$1"
    shift

    bprint "$C_INFO" "$title"
    echo
    for item in "$@"; do
        cprint "$C_MUTED" "  $ICON_BULLET $item"
        echo
    done
}

# Code block
code_block() {
    local code="$1"
    local width=60

    cprint "$C_DIM" "$BOX_TL$(hline $((width-2)))$BOX_TR"
    echo

    while IFS= read -r line; do
        printf "${C_DIM}$BOX_V ${C_SECONDARY}%-$((width-4))s${C_DIM} $BOX_V${RST}\n" "$line"
    done <<< "$code"

    cprint "$C_DIM" "$BOX_BL$(hline $((width-2)))$BOX_BR"
    echo
}

# Framed box with title
framed_box() {
    local content="$1"
    local title="${2:-}"
    local color="${3:-$C_PRIMARY}"
    local width=60

    # Top border
    if [[ -n "$title" ]]; then
        printf "${color}$BOX_TL$BOX_H $title "
        local title_len=$((${#title} + 3))
        cprint "$color" "$(hline $((width - title_len - 2)))"
        printf "${color}$BOX_TR${RST}\n"
    else
        cprint "$color" "$BOX_TL$(hline $((width-2)))$BOX_TR"
        echo
    fi

    # Content
    while IFS= read -r line; do
        printf "${color}$BOX_V${RST} %-$((width-4))s ${color}$BOX_V${RST}\n" "$line"
    done <<< "$content"

    # Bottom border
    cprint "$color" "$BOX_BL$(hline $((width-2)))$BOX_BR"
    echo
}

# =============================================================================
# LESSON CONTENT
# =============================================================================

# Get max steps for a lesson
max_steps() {
    case "$1" in
        1) echo 4 ;;
        2) echo 5 ;;
        3) echo 5 ;;
        4) echo 5 ;;
        5) echo 4 ;;
        *) echo 1 ;;
    esac
}

# -----------------------------------------------------------------------------
# HOME SCREEN
# -----------------------------------------------------------------------------

render_home() {
    cat << 'BANNER'
   _                    _      _             _     _ _            _
  /_\  __ _ ___ _ _  | |_   /_\  _ _ __| |_ (_) |_ ___ __| |_ _  _ _ _ ___
 / _ \/ _` / -_) ' \ |  _| / _ \| '_/ _| ' \| |  _/ -_) _|  _| || | '_/ -_)
/_/ \_\__, \___|_||_| \__| /_/ \_\_| \__|_||_|_|\__\___\__|\__|\___|_| \___|
      |___/
BANNER
    echo
    bprint "$C_ACCENT" "        Interactive Terminal Tutorial • January 2026"
    echo
    echo
    cprint "$C_TEXT" "Learn modern AI agent architecture through hands-on examples."
    echo
    cprint "$C_TEXT" "Based on research from Anthropic, Manus, Cursor, and Fly.io."
    echo
    echo
    cprint "$C_DIM" "$(hline 60)"
    echo
    echo
    bprint "$C_SECONDARY" "LESSONS"
    echo
    echo
    cprint "$C_ACCENT" "  [1]"; cprint "$C_TEXT" " The Agent Loop          "; cprint "$C_MUTED" "Unix primitives and the core loop"; echo
    cprint "$C_ACCENT" "  [2]"; cprint "$C_TEXT" " Context Engineering     "; cprint "$C_MUTED" "The new critical skill"; echo
    cprint "$C_ACCENT" "  [3]"; cprint "$C_TEXT" " Multi-Agent Patterns    "; cprint "$C_MUTED" "Plan/Execute/Task architecture"; echo
    cprint "$C_ACCENT" "  [4]"; cprint "$C_TEXT" " Inside Claude Code      "; cprint "$C_MUTED" "Tools, CLAUDE.md, and design"; echo
    cprint "$C_ACCENT" "  [5]"; cprint "$C_TEXT" " Build Your Own Agent    "; cprint "$C_MUTED" "Three tracks to mastery"; echo
    echo
    cprint "$C_DIM" "$(hline 60)"
    echo
    echo
    bprint "$C_SECONDARY" "KEY CONCEPTS YOU'LL LEARN"
    echo
    echo
    cprint "$C_MUTED" "  $ICON_BULLET The \"Agent-with-a-Computer\" paradigm"; echo
    cprint "$C_MUTED" "  $ICON_BULLET Context engineering vs prompt engineering"; echo
    cprint "$C_MUTED" "  $ICON_BULLET KV-cache optimization for 10x cost savings"; echo
    cprint "$C_MUTED" "  $ICON_BULLET Plan/Execution/Task multi-agent pattern"; echo
    cprint "$C_MUTED" "  $ICON_BULLET The Bitter Lesson applied to agents"; echo
    echo
    cprint "$C_DIM" "$(hline 60)"
    echo
    echo
    cprint "$C_SUCCESS" "[Enter]"; cprint "$C_MUTED" " Start   "
    cprint "$C_INFO" "[1-5]"; cprint "$C_MUTED" " Jump to lesson   "
    cprint "$C_ERROR" "[q]"; cprint "$C_MUTED" " Quit"
    echo
}

# -----------------------------------------------------------------------------
# LESSON 1: THE AGENT LOOP
# -----------------------------------------------------------------------------

render_lesson1() {
    lesson_header 1 "The Agent Loop"
    echo

    case "$STEP" in
        0) # Introduction
            cprint "$C_TEXT" "$ICON_ROBOT Every AI agent—from simple chatbots to complex autonomous"
            echo
            cprint "$C_TEXT" "systems—follows the same fundamental pattern."
            echo
            echo
            bprint "$C_ACCENT" "The Big Insight:"
            echo
            echo
            cprint "$C_TEXT" "  An agent is just a "; bprint "$C_SUCCESS" "loop"; cprint "$C_TEXT" " that:"
            echo
            cprint "$C_MUTED" "    1. Gathers context"
            echo
            cprint "$C_MUTED" "    2. Calls an LLM"
            echo
            cprint "$C_MUTED" "    3. Executes any tool calls"
            echo
            cprint "$C_MUTED" "    4. Repeats until done"
            echo
            echo
            cprint "$C_INFO" "That's it. Everything else is optimization and specialization."
            echo
            ;;

        1) # Core Loop
            bprint "$C_ACCENT" "The Core Loop (in Bash)"
            echo
            echo
            cprint "$C_MUTED" "Here's the agentic loop expressed as a shell script:"
            echo
            echo
            code_block 'while true; do
  # 1. Build context from prompt + history
  CONTEXT=$(cat prompt.txt history.txt)

  # 2. Send to LLM, get response
  RESPONSE=$(echo "$CONTEXT" | llm)

  # 3. Check if response contains a tool call
  if has_tool_call "$RESPONSE"; then
    # 4. Execute the tool
    RESULT=$(execute_tool "$RESPONSE")
    echo "$RESULT" >> history.txt
  else
    # 5. No tool call = final answer
    echo "$RESPONSE"
    break
  fi
done'
            echo
            concept_list "Key Components:" \
                "Context = System prompt + Conversation history" \
                "Tool calls are detected in the response" \
                "History accumulates across iterations" \
                "Loop exits when LLM gives a final answer"
            ;;

        2) # Minimal Agent
            bprint "$C_ACCENT" "A Real Minimal Agent"
            echo
            echo
            cprint "$C_MUTED" "Here's a working agent using just curl and jq:"
            echo
            echo
            code_block '#!/bin/bash
ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:?Set key}"

agent() {
  curl -s https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "content-type: application/json" \
    -H "anthropic-version: 2023-06-01" \
    -d "{
      \"model\": \"claude-sonnet-4-20250514\",
      \"max_tokens\": 1024,
      \"messages\": [{\"role\": \"user\",
        \"content\": \"$1\"}]
    }" | jq -r ".content[0].text"
}'
            echo
            cprint "$C_INFO" "$ICON_LIGHTNING This is a single-turn agent. Multi-turn agents"
            echo
            cprint "$C_INFO" "   maintain history across calls."
            echo
            ;;

        3) # Takeaways
            bprint "$C_ACCENT" "$ICON_STAR Key Takeaways"
            echo
            echo
            check_item "Agents are loops, not magic" \
                "The complexity comes from tool definitions, not the loop itself."
            echo
            check_item "Context is everything" \
                "What you put in the context window determines behavior."
            echo
            check_item "Tool calls extend capabilities" \
                "The LLM decides when to use tools; you define what's available."
            echo
            check_item "History enables multi-turn reasoning" \
                "Appending results lets the agent build on previous actions."
            echo
            echo
            cprint "$C_PRIMARY" "$ICON_ARROW "
            bprint "$C_PRIMARY" "Next: Context Engineering—the new critical skill"
            echo
            ;;
    esac

    echo
    printf "  Progress: "
    progress_bar $((STEP + 1)) 4 30
    echo
    nav_hints
}

# -----------------------------------------------------------------------------
# LESSON 2: CONTEXT ENGINEERING
# -----------------------------------------------------------------------------

render_lesson2() {
    lesson_header 2 "Context Engineering"
    echo

    case "$STEP" in
        0) # Definition
            cprint "$C_TEXT" "$ICON_LIGHTNING "; bprint "$C_TEXT" "Context engineering"; cprint "$C_TEXT" " has replaced prompt"
            echo
            cprint "$C_TEXT" "engineering as the primary skill for building effective agents."
            echo
            echo
            framed_box '"What configuration of context is most likely
to generate our model'"'"'s desired behavior?"

                                    — Anthropic' "Definition" "$C_ACCENT"
            echo
            cprint "$C_INFO" "The context window is your most precious resource."
            echo
            cprint "$C_INFO" "How you fill it determines everything."
            echo
            ;;

        1) # Demo
            bprint "$C_ACCENT" "Demo: Log Analysis"
            echo
            echo
            cprint "$C_TEXT" "Task: Analyze a 10MB log file for error patterns."
            echo
            echo
            cprint "$C_ERROR" "Option A:"; cprint "$C_MUTED" " Load entire file into context"
            echo
            cprint "$C_SUCCESS" "Option B:"; cprint "$C_MUTED" " Write a grep script to extract errors"
            echo
            echo
            cprint "$C_TEXT" "Context Window Comparison:"
            echo
            echo
            printf "  Option A: "
            progress_bar 95 100 30
            echo
            cprint "$C_ERROR" "           $ICON_CROSS Context overflow after 3 tool calls"
            echo
            echo
            printf "  Option B: "
            progress_bar 15 100 30
            echo
            cprint "$C_SUCCESS" "           $ICON_CHECK 200 tokens used, handles any log size"
            echo
            echo
            cprint "$C_INFO" "The lesson: Act on data without loading it all into context."
            echo
            ;;

        2) # Strategies
            bprint "$C_ACCENT" "Core Strategies"
            echo
            echo
            bprint "$C_SUCCESS" "1. Progressive Disclosure"
            echo
            cprint "$C_MUTED" "   $ICON_BULLET Start minimal, let the agent accumulate context"
            echo
            cprint "$C_MUTED" "   $ICON_BULLET Include usage hints in tool outputs (just-in-time)"
            echo
            cprint "$C_MUTED" "   $ICON_BULLET Use README.md files the agent reads on demand"
            echo
            echo
            bprint "$C_SUCCESS" "2. Context Indirection"
            echo
            cprint "$C_MUTED" "   $ICON_BULLET Let agents act on data without seeing all of it"
            echo
            cprint "$C_MUTED" "   $ICON_BULLET Write grep/awk scripts instead of loading files"
            echo
            cprint "$C_MUTED" "   $ICON_BULLET Manus achieves 100:1 compression ratios this way"
            echo
            echo
            bprint "$C_SUCCESS" "3. Leverage Model Priors"
            echo
            cprint "$C_MUTED" "   $ICON_BULLET Use libraries models already know (pandas, numpy)"
            echo
            cprint "$C_MUTED" "   $ICON_BULLET Convert legacy formats to JSON/YAML on read"
            echo
            cprint "$C_MUTED" "   $ICON_BULLET Avoid custom DSLs the model hasn't seen"
            echo
            ;;

        3) # KV Cache
            bprint "$C_ACCENT" "The KV-Cache Optimization"
            echo
            echo
            cprint "$C_TEXT" "Manus identifies KV-cache hit rate as "
            bprint "$C_SUCCESS" "the single most"
            echo
            bprint "$C_SUCCESS" "important metric"
            cprint "$C_TEXT" " for production agents."
            echo
            echo
            printf "${C_ACCENT}%-28s${C_SUCCESS}%-28s${RST}\n" "Token Type" "Cost (Claude Sonnet)"
            cprint "$C_DIM" "$(hline 56)"
            echo
            printf "${C_MUTED}%-28s${C_TEXT}%-28s${RST}\n" "Cached input tokens" "\$0.30 / MTok"
            printf "${C_MUTED}%-28s${C_TEXT}%-28s${RST}\n" "Uncached input tokens" "\$3.00 / MTok"
            printf "${C_MUTED}%-28s${C_TEXT}%-28s${RST}\n" "Savings" "10x difference!"
            echo
            echo
            bprint "$C_INFO" "Rules for High Cache Hit Rates:"
            echo
            cprint "$C_MUTED" "  $ICON_BULLET Keep prompt prefix stable (1 token change = cache miss)"
            echo
            cprint "$C_MUTED" "  $ICON_BULLET Use append-only context when possible"
            echo
            cprint "$C_MUTED" "  $ICON_BULLET Consistent tool result serialization"
            echo
            ;;

        4) # Takeaways
            bprint "$C_ACCENT" "$ICON_STAR Key Takeaways"
            echo
            echo
            check_item "Context is finite and precious" \
                "Every token has a cost—both financially and cognitively."
            echo
            check_item "Indirection beats inclusion" \
                "Write scripts to process data rather than loading it all."
            echo
            check_item "Cache hits = cost savings" \
                "Stable prefixes can reduce costs by 10x."
            echo
            check_item "Progressive disclosure scales" \
                "Start small, add context only when needed."
            echo
            echo
            cprint "$C_PRIMARY" "$ICON_ARROW "
            bprint "$C_PRIMARY" "Next: Multi-Agent Patterns"
            echo
            ;;
    esac

    echo
    printf "  Progress: "
    progress_bar $((STEP + 1)) 5 30
    echo
    nav_hints
}

# -----------------------------------------------------------------------------
# LESSON 3: MULTI-AGENT PATTERNS
# -----------------------------------------------------------------------------

render_lesson3() {
    lesson_header 3 "Multi-Agent Patterns"
    echo

    case "$STEP" in
        0) # When
            cprint "$C_TEXT" "$ICON_ROBOT Not every problem needs multiple agents. Understanding"
            echo
            cprint "$C_TEXT" "when to use them is crucial."
            echo
            echo
            printf "${C_ACCENT}%-28s${C_SUCCESS}%-28s${RST}\n" "Single Agent" "Multi-Agent"
            cprint "$C_DIM" "$(hline 56)"
            echo
            printf "${C_MUTED}%-28s${C_TEXT}%-28s${RST}\n" "Sequential tasks" "Parallelizable work"
            printf "${C_MUTED}%-28s${C_TEXT}%-28s${RST}\n" "Small context needs" "Large/varied contexts"
            printf "${C_MUTED}%-28s${C_TEXT}%-28s${RST}\n" "Simple workflows" "Complex coordination"
            printf "${C_MUTED}%-28s${C_TEXT}%-28s${RST}\n" "Quick iterations" "Long-running tasks"
            echo
            echo
            framed_box "Warning: Multi-agent adds complexity. Start simple,
add agents only when single-agent fails." "" "$C_WARNING"
            ;;

        1) # Pattern
            bprint "$C_ACCENT" "The Plan/Execution/Task Pattern"
            echo
            echo
            cprint "$C_MUTED" "Modern agents converge on three roles:"
            echo
            echo
            bprint "$C_INFO" "  $ICON_STAR Plan Agent"
            echo
            cprint "$C_MUTED" "  Discovery, mapping, generating pointers"
            echo
            cprint "$C_DIM" "  Scope: Broad context, strategic decisions"
            echo
            echo
            bprint "$C_SUCCESS" "  $ICON_CODE Execution Agent"
            echo
            cprint "$C_MUTED" "  Builds things given a plan, writes scripts, verifies"
            echo
            cprint "$C_DIM" "  Scope: Full task, hands-on implementation"
            echo
            echo
            bprint "$C_SECONDARY" "  $ICON_LIGHTNING Task Agent"
            echo
            cprint "$C_MUTED" "  Transient sub-agent for parallel/isolated work"
            echo
            cprint "$C_DIM" "  Scope: Single chunk of work, ephemeral"
            echo
            echo
            cprint "$C_MUTED" "This replaces hand-crafted \"SQL Specialist\" subagents."
            echo
            ;;

        2) # Demo
            bprint "$C_ACCENT" "Demo: Process 100 Records"
            echo
            echo
            cprint "$C_TEXT" "Single Agent (Sequential):"
            echo
            printf "  "
            progress_bar 70 100 40
            echo
            cprint "$C_MUTED" "  Processing... ~5 seconds total"
            echo
            echo
            cprint "$C_TEXT" "Plan Agent + 5 Task Agents (Parallel):"
            echo
            printf "  Task 1: "; progress_bar 100 100 20; cprint "$C_SUCCESS" " $ICON_CHECK"; echo
            printf "  Task 2: "; progress_bar 100 100 20; cprint "$C_SUCCESS" " $ICON_CHECK"; echo
            printf "  Task 3: "; progress_bar 100 100 20; cprint "$C_SUCCESS" " $ICON_CHECK"; echo
            printf "  Task 4: "; progress_bar 100 100 20; cprint "$C_SUCCESS" " $ICON_CHECK"; echo
            printf "  Task 5: "; progress_bar 100 100 20; cprint "$C_SUCCESS" " $ICON_CHECK"; echo
            cprint "$C_SUCCESS" "  Completed in ~1 second (5x faster!)"
            echo
            ;;

        3) # Cursor
            bprint "$C_ACCENT" "Cursor's Multi-Agent Research"
            echo
            echo
            cprint "$C_MUTED" "Cursor ran experiments with hundreds of concurrent agents:"
            echo
            echo
            cprint "$C_INFO" "  $ICON_CODE Built a web browser from scratch: 1M+ lines, 1000 files"
            echo
            echo
            cprint "$C_ERROR" "  $ICON_CROSS Dynamic coordination (self-coordinating) FAILED"
            echo
            cprint "$C_DIM" "       Lock contention, race conditions, chaos"
            echo
            echo
            cprint "$C_SUCCESS" "  $ICON_CHECK Static planning with central planner SUCCEEDED"
            echo
            cprint "$C_DIM" "       Single source of truth for task assignment"
            echo
            echo
            cprint "$C_WARNING" "  $ICON_STAR Used \"judge agent\" at cycle end to decide continuation"
            echo
            echo
            cprint "$C_INFO" "  $ICON_LIGHTNING Fresh context periodically to combat drift"
            echo
            ;;

        4) # Takeaways
            bprint "$C_ACCENT" "$ICON_STAR Key Takeaways"
            echo
            echo
            check_item "Central planning beats dynamic coordination" \
                "A single planner prevents chaos in multi-agent systems."
            echo
            check_item "Task agents should be ephemeral" \
                "Spawn, execute, return results, terminate."
            echo
            check_item "Fresh context prevents drift" \
                "Long-running agents accumulate errors; reset periodically."
            echo
            check_item "Judge agents validate completeness" \
                "Separate verification from execution."
            echo
            echo
            cprint "$C_PRIMARY" "$ICON_ARROW "
            bprint "$C_PRIMARY" "Next: Inside Claude Code"
            echo
            ;;
    esac

    echo
    printf "  Progress: "
    progress_bar $((STEP + 1)) 5 30
    echo
    nav_hints
}

# -----------------------------------------------------------------------------
# LESSON 4: INSIDE CLAUDE CODE
# -----------------------------------------------------------------------------

render_lesson4() {
    lesson_header 4 "Inside Claude Code"
    echo

    case "$STEP" in
        0) # Overview
            cprint "$C_TEXT" "$ICON_CODE "; bprint "$C_TEXT" "Claude Code"; cprint "$C_TEXT" " is Anthropic's official CLI for Claude—"
            echo
            cprint "$C_TEXT" "a reference implementation of \"Agent-with-a-Computer.\""
            echo
            echo
            bprint "$C_ACCENT" "The Architecture:"
            echo
            cprint "$C_MUTED" "  $ICON_BULLET Full access to filesystem, terminal, and code execution"
            echo
            cprint "$C_MUTED" "  $ICON_BULLET Persistent environment (not ephemeral containers)"
            echo
            cprint "$C_MUTED" "  $ICON_BULLET Progressive disclosure via CLAUDE.md files"
            echo
            cprint "$C_MUTED" "  $ICON_BULLET Generic tools instead of domain-specific ones"
            echo
            echo
            framed_box "$ICON_LIGHTNING Key insight: The same architecture works for
coding AND non-coding tasks. Power users manage
emails and todo lists with it!" "" "$C_INFO"
            ;;

        1) # Tools
            bprint "$C_ACCENT" "Core Tools"
            echo
            echo
            cprint "$C_TEXT" "Claude Code has surprisingly few tools—and that's intentional:"
            echo
            echo
            bprint "$C_SECONDARY" "  bash  "; cprint "$C_MUTED" "— Run any terminal command"; echo
            cprint "$C_DIM" "          Example: npm install, git status, pytest"; echo
            echo
            bprint "$C_SECONDARY" "  read  "; cprint "$C_MUTED" "— View file contents"; echo
            cprint "$C_DIM" "          Example: Read src/index.ts"; echo
            echo
            bprint "$C_SECONDARY" "  write "; cprint "$C_MUTED" "— Create or replace entire files"; echo
            cprint "$C_DIM" "          Example: Write src/Button.tsx"; echo
            echo
            bprint "$C_SECONDARY" "  edit  "; cprint "$C_MUTED" "— Surgical string replacement"; echo
            cprint "$C_DIM" "          Example: Change \"x = 1\" to \"x = 2\""; echo
            echo
            bprint "$C_SECONDARY" "  glob  "; cprint "$C_MUTED" "— Find files by pattern"; echo
            bprint "$C_SECONDARY" "  grep  "; cprint "$C_MUTED" "— Search file contents"; echo
            echo
            cprint "$C_INFO" "$ICON_STAR Notice: All generic Unix-style operations. No domain-specific tools."
            echo
            ;;

        2) # CLAUDE.md
            bprint "$C_ACCENT" "The CLAUDE.md File"
            echo
            echo
            cprint "$C_TEXT" "CLAUDE.md is project-specific context that Claude reads"
            echo
            cprint "$C_TEXT" "automatically. It's the primary mechanism for progressive disclosure."
            echo
            echo
            code_block '# CLAUDE.md

## Project Overview
This is a Next.js app using:
- TypeScript with strict mode
- Prisma for database

## Commands
- `npm run dev` - Start dev server
- `npm run test` - Run tests

## Code Style
- Use functional components
- Prefer named exports'
            echo
            cprint "$C_INFO" "$ICON_STAR Tip: Put CLAUDE.md in subdirectories for module-specific instructions."
            echo
            ;;

        3) # Bitter Lesson
            bprint "$C_ACCENT" "The Bitter Lesson Applied"
            echo
            echo
            framed_box '"If model progress is the rising tide, we want
to be the boat, not the pillar stuck to the seabed."

                                        — Manus Team' "" "$C_WARNING"
            echo
            cprint "$C_TEXT" "Boris Cherny (Claude Code creator) cited the Bitter Lesson"
            echo
            cprint "$C_TEXT" "as influencing the decision to keep Claude Code \"unopinionated.\""
            echo
            echo
            cprint "$C_SUCCESS" "  $ICON_CHECK Generic tools over domain-specific ones"
            echo
            cprint "$C_SUCCESS" "  $ICON_CHECK Let the model figure out how to use them"
            echo
            cprint "$C_SUCCESS" "  $ICON_CHECK Remove complexity, don't add it"
            echo
            cprint "$C_SUCCESS" "  $ICON_CHECK Adapt to model improvements automatically"
            echo
            echo
            cprint "$C_MUTED" "Manus rebuilt their agent framework 5 times in 6 months."
            echo
            cprint "$C_MUTED" "Each gain came from removing complexity, not adding it."
            echo
            ;;

        4) # Takeaways
            bprint "$C_ACCENT" "$ICON_STAR Key Takeaways"
            echo
            echo
            check_item "Fewer tools is often better" \
                "Generic capabilities beat specialized ones."
            echo
            check_item "CLAUDE.md enables progressive disclosure" \
                "Project context on demand, not upfront."
            echo
            check_item "Bet on model improvements" \
                "Build harnesses that benefit from smarter models."
            echo
            check_item "The computer IS the tool" \
                "File system + bash + code execution = universal capability."
            echo
            echo
            cprint "$C_PRIMARY" "$ICON_ARROW "
            bprint "$C_PRIMARY" "Next: Build Your Own Agent"
            echo
            ;;
    esac

    echo
    printf "  Progress: "
    progress_bar $((STEP + 1)) 5 30
    echo
    nav_hints
}

# -----------------------------------------------------------------------------
# LESSON 5: BUILD YOUR OWN AGENT
# -----------------------------------------------------------------------------

render_lesson5() {
    lesson_header 5 "Build Your Own Agent"
    echo

    case "$STEP" in
        0) # Choose Track
            bprint "$C_ACCENT" "Choose Your Path"
            echo
            echo
            cprint "$C_TEXT" "Three approaches to building agents:"
            echo
            echo

            local unix_color="$C_TEXT"
            local sdk_color="$C_TEXT"
            local beam_color="$C_TEXT"
            [[ "$SELECTED_TRACK" == "unix" ]] && unix_color="$C_SUCCESS"
            [[ "$SELECTED_TRACK" == "sdk" ]] && sdk_color="$C_SUCCESS"
            [[ "$SELECTED_TRACK" == "beam" ]] && beam_color="$C_SUCCESS"

            cprint "$C_SECONDARY" "  [1]"
            cprint "$unix_color" " $ICON_SHELL Unix Track"
            echo
            cprint "$C_MUTED" "      Build an agent using only bash, jq, and curl."
            echo
            cprint "$C_DIM" "      Best for: Learning fundamentals, quick prototypes"
            echo
            echo
            cprint "$C_SECONDARY" "  [2]"
            cprint "$sdk_color" " $ICON_ROBOT Anthropic SDK Track"
            echo
            cprint "$C_MUTED" "      Use the official SDK with proper tool definitions."
            echo
            cprint "$C_DIM" "      Best for: Production agents, full feature access"
            echo
            echo
            cprint "$C_SECONDARY" "  [3]"
            cprint "$beam_color" " $ICON_BEAM BEAM Track (Advanced)"
            echo
            cprint "$C_MUTED" "      Orchestrate agents with Elixir/OTP supervision."
            echo
            cprint "$C_DIM" "      Best for: Fault-tolerant, distributed systems"
            echo
            echo

            if [[ -n "$SELECTED_TRACK" ]]; then
                cprint "$C_SUCCESS" "Selected: $(echo "$SELECTED_TRACK" | tr '[:lower:]' '[:upper:]') Track — Press → to continue"
            else
                cprint "$C_DIM" "Press 1, 2, or 3 to select a track"
            fi
            echo
            ;;

        1) # Code
            local title code
            case "$SELECTED_TRACK" in
                unix)
                    title="Unix Agent (Bash)"
                    code='#!/bin/bash
call_claude() {
  curl -s https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "content-type: application/json" \
    -d "{
      \"model\": \"claude-sonnet-4-20250514\",
      \"max_tokens\": 1024,
      \"messages\": $1
    }" | jq -r ".content[0].text"
}'
                    ;;
                beam)
                    title="BEAM Agent (Elixir)"
                    code='defmodule MyAgent do
  use Jido.Agent, name: "my_agent"

  def execute(task) do
    {:ok, plan} = plan_task(task)

    plan.subtasks
    |> Task.async_stream(&execute_subtask/1,
         max_concurrency: 10)
    |> Enum.map(fn {:ok, r} -> r end)
  end
end'
                    ;;
                *)
                    title="SDK Agent (TypeScript)"
                    code='const client = new Anthropic();

async function agent(task: string) {
  const messages = [{ role: "user", content: task }];

  while (true) {
    const response = await client.messages.create({
      model: "claude-sonnet-4-20250514",
      tools, messages
    });

    if (response.stop_reason === "end_turn") {
      return response.content[0].text;
    }
    // Execute tools and continue...
  }
}'
                    ;;
            esac

            bprint "$C_ACCENT" "$title"
            echo
            echo
            code_block "$code"
            echo
            cprint "$C_INFO" "$ICON_STAR This is the core pattern. See examples/ for complete implementations."
            echo
            ;;

        2) # Next Steps
            local track_name="${SELECTED_TRACK:-sdk}"
            track_name="$(echo "$track_name" | tr '[:lower:]' '[:upper:]')"

            bprint "$C_ACCENT" "Next Steps for $track_name Track"
            echo
            echo

            case "$SELECTED_TRACK" in
                unix)
                    cprint "$C_MUTED" "  1. Add tool parsing with grep/sed for <tool_call> tags"
                    echo
                    cprint "$C_MUTED" "  2. Implement history management with temp files"
                    echo
                    cprint "$C_MUTED" "  3. Add error handling for API failures"
                    echo
                    cprint "$C_MUTED" "  4. Create tool executor functions"
                    echo
                    ;;
                beam)
                    cprint "$C_MUTED" "  1. Set up a new Phoenix/Elixir project"
                    echo
                    cprint "$C_MUTED" "  2. Add Jido and configure supervisors"
                    echo
                    cprint "$C_MUTED" "  3. Define agent schemas and actions"
                    echo
                    cprint "$C_MUTED" "  4. Implement the Claude API integration"
                    echo
                    cprint "$C_MUTED" "  5. Add LiveView for real-time UI"
                    echo
                    ;;
                *)
                    cprint "$C_MUTED" "  1. Install @anthropic-ai/sdk package"
                    echo
                    cprint "$C_MUTED" "  2. Define your tool schemas"
                    echo
                    cprint "$C_MUTED" "  3. Implement tool execution handlers"
                    echo
                    cprint "$C_MUTED" "  4. Add context management"
                    echo
                    cprint "$C_MUTED" "  5. Consider adding memory/state persistence"
                    echo
                    ;;
            esac
            echo
            framed_box "$ICON_STAR Pro tip: Start with the simplest version that
works, then add complexity only when needed.
Remember the Bitter Lesson!" "" "$C_INFO"
            ;;

        3) # Summary
            bprint "$C_ACCENT" "$ICON_STAR Congratulations!"
            echo
            echo
            cprint "$C_TEXT" "You've completed the Agent Architecture Tutorial!"
            echo
            echo
            cprint "$C_SUCCESS" "$ICON_CHECK "; bprint "$C_TEXT" "Lesson 1:"; cprint "$C_MUTED" " The agent loop is just a while loop"; echo
            cprint "$C_SUCCESS" "$ICON_CHECK "; bprint "$C_TEXT" "Lesson 2:"; cprint "$C_MUTED" " Context engineering is the key skill"; echo
            cprint "$C_SUCCESS" "$ICON_CHECK "; bprint "$C_TEXT" "Lesson 3:"; cprint "$C_MUTED" " Multi-agent needs central planning"; echo
            cprint "$C_SUCCESS" "$ICON_CHECK "; bprint "$C_TEXT" "Lesson 4:"; cprint "$C_MUTED" " Generic tools beat specialized ones"; echo
            cprint "$C_SUCCESS" "$ICON_CHECK "; bprint "$C_TEXT" "Lesson 5:"; cprint "$C_MUTED" " Start simple, add complexity as needed"; echo
            echo
            framed_box "The Central Thesis:

\"All agents will become coding agents.\"

The LLM + Computer architecture is exceptionally
powerful regardless of whether your task involves
writing code." "" "$C_PRIMARY"
            echo
            cprint "$C_MUTED" "Press → to exit, or explore the example files."
            echo
            ;;
    esac

    echo
    printf "  Progress: "
    progress_bar $((STEP + 1)) 4 30
    echo
    nav_hints
}

# -----------------------------------------------------------------------------
# COMPLETION SCREEN
# -----------------------------------------------------------------------------

render_complete() {
    echo
    echo
    bprint "$C_SUCCESS" "        🎉 Tutorial Complete! 🎉"
    echo
    echo
    cprint "$C_TEXT" "You now understand the foundations of modern agent architecture."
    echo
    echo
    bprint "$C_ACCENT" "What's Next?"
    echo
    cprint "$C_MUTED" "  $ICON_BULLET Explore ./examples/ for working code samples"
    echo
    cprint "$C_MUTED" "  $ICON_BULLET Try building an agent with the Anthropic SDK"
    echo
    cprint "$C_MUTED" "  $ICON_BULLET Read the full research synthesis in the docs"
    echo
    cprint "$C_MUTED" "  $ICON_BULLET Experiment with Claude Code on your own projects"
    echo
    echo
    cprint "$C_DIM" "$(hline 60)"
    echo
    echo
    cprint "$C_INFO" "[r]"
    cprint "$C_MUTED" " Restart tutorial  "
    cprint "$C_ERROR" "[q]"
    cprint "$C_MUTED" " Quit"
    echo
}

# =============================================================================
# RENDERING
# =============================================================================

render() {
    clear_screen
    move_cursor 1 1

    case "$SCREEN" in
        home)      render_home ;;
        lesson1)   render_lesson1 ;;
        lesson2)   render_lesson2 ;;
        lesson3)   render_lesson3 ;;
        lesson4)   render_lesson4 ;;
        lesson5)   render_lesson5 ;;
        complete)  render_complete ;;
        *)         render_home ;;
    esac
}

# =============================================================================
# INPUT HANDLING
# =============================================================================

handle_input() {
    local key="$1"

    case "$SCREEN" in
        home)
            case "$key" in
                q) return 1 ;;
                ""|$'\n'|$'\r') SCREEN="lesson1"; LESSON=1; STEP=0 ;;
                1) SCREEN="lesson1"; LESSON=1; STEP=0 ;;
                2) SCREEN="lesson2"; LESSON=2; STEP=0 ;;
                3) SCREEN="lesson3"; LESSON=3; STEP=0 ;;
                4) SCREEN="lesson4"; LESSON=4; STEP=0 ;;
                5) SCREEN="lesson5"; LESSON=5; STEP=0 ;;
            esac
            ;;

        lesson*)
            case "$key" in
                q) return 1 ;;
                n|D)  # n or right arrow (escape sequence ends with D for some terms, C for others)
                    local max
                    max=$(max_steps "$LESSON")
                    if [[ $STEP -lt $((max - 1)) ]]; then
                        ((STEP++))
                    else
                        if [[ $LESSON -lt 5 ]]; then
                            ((LESSON++))
                            SCREEN="lesson$LESSON"
                            STEP=0
                        else
                            SCREEN="complete"
                        fi
                    fi
                    ;;
                p|C)  # p or left arrow
                    if [[ $STEP -gt 0 ]]; then
                        ((STEP--))
                    else
                        if [[ $LESSON -gt 1 ]]; then
                            ((LESSON--))
                            SCREEN="lesson$LESSON"
                            STEP=$(($(max_steps "$LESSON") - 1))
                        else
                            SCREEN="home"
                        fi
                    fi
                    ;;
                1|2|3)
                    # Track selection in lesson 5, step 0
                    if [[ "$SCREEN" == "lesson5" && $STEP -eq 0 ]]; then
                        case "$key" in
                            1) SELECTED_TRACK="unix" ;;
                            2) SELECTED_TRACK="sdk" ;;
                            3) SELECTED_TRACK="beam" ;;
                        esac
                    fi
                    ;;
            esac
            ;;

        complete)
            case "$key" in
                q) return 1 ;;
                r) SCREEN="home"; LESSON=1; STEP=0; SELECTED_TRACK="" ;;
            esac
            ;;
    esac

    return 0
}

# Read a single keypress (handles escape sequences for arrow keys)
read_key() {
    local key
    IFS= read -rsn1 key

    # Handle escape sequences (arrow keys)
    if [[ "$key" == $'\e' ]]; then
        read -rsn2 -t 0.1 seq
        case "$seq" in
            '[A') key="up" ;;      # Up arrow
            '[B') key="down" ;;    # Down arrow
            '[C') key="n" ;;       # Right arrow -> next
            '[D') key="p" ;;       # Left arrow -> prev
        esac
    fi

    echo "$key"
}

# =============================================================================
# MAIN LOOP
# =============================================================================

cleanup() {
    show_cursor
    alt_screen_off
    stty echo 2>/dev/null || true
    echo
    echo "Thanks for using the Agent Architecture Tutorial!"
}

main() {
    # Set up cleanup on exit
    trap cleanup EXIT INT TERM

    # Initialize terminal
    alt_screen_on
    hide_cursor
    stty -echo 2>/dev/null || true

    # Main event loop
    while true; do
        render

        local key
        key=$(read_key)

        if ! handle_input "$key"; then
            break
        fi
    done
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
