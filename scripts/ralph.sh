#!/bin/bash
#
# Ralph for Claude Code - Autonomous AI Agent Loop
# Adapted from https://github.com/snarktank/ralph for Claude Code CLI
#
# Usage: ./scripts/ralph.sh [max_iterations]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
MAX_ITERATIONS=${1:-10}

PRD_FILE="$PROJECT_DIR/prd.json"
PROGRESS_FILE="$PROJECT_DIR/progress.txt"
PROMPT_FILE="$PROJECT_DIR/prompt.md"
LAST_BRANCH_FILE="$PROJECT_DIR/.last-branch"
ARCHIVE_DIR="$PROJECT_DIR/.ralph-archive"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[Ralph]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[Ralph]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[Ralph]${NC} $1"
}

log_error() {
    echo -e "${RED}[Ralph]${NC} $1"
}

# Check required files exist
if [[ ! -f "$PRD_FILE" ]]; then
    log_error "PRD file not found at $PRD_FILE"
    log_info "Create a prd.json file or copy from prd.json.example"
    exit 1
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
    log_error "Prompt file not found at $PROMPT_FILE"
    exit 1
fi

# Check if claude CLI is available
if ! command -v claude &> /dev/null; then
    log_error "Claude Code CLI not found. Please install it first."
    log_info "Visit: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

# Get current branch from PRD
get_prd_branch() {
    if command -v jq &> /dev/null; then
        jq -r '.branchName // "main"' "$PRD_FILE"
    else
        grep -o '"branchName"[[:space:]]*:[[:space:]]*"[^"]*"' "$PRD_FILE" | sed 's/.*"branchName"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
    fi
}

# Archive previous run if branch changed
archive_if_branch_changed() {
    local current_branch=$(get_prd_branch)

    if [[ -f "$LAST_BRANCH_FILE" ]]; then
        local last_branch=$(cat "$LAST_BRANCH_FILE")

        if [[ "$last_branch" != "$current_branch" ]]; then
            log_info "Branch changed from $last_branch to $current_branch"

            # Create archive directory
            local archive_name="${last_branch//\//-}-$(date +%Y%m%d-%H%M%S)"
            local archive_path="$ARCHIVE_DIR/$archive_name"
            mkdir -p "$archive_path"

            # Archive files
            [[ -f "$PRD_FILE" ]] && cp "$PRD_FILE" "$archive_path/"
            [[ -f "$PROGRESS_FILE" ]] && cp "$PROGRESS_FILE" "$archive_path/"

            log_success "Archived previous run to $archive_path"

            # Reset progress for new branch
            echo "## Codebase Patterns" > "$PROGRESS_FILE"
            echo "" >> "$PROGRESS_FILE"
            echo "---" >> "$PROGRESS_FILE"
            echo "" >> "$PROGRESS_FILE"
        fi
    fi

    echo "$current_branch" > "$LAST_BRANCH_FILE"
}

# Initialize progress file if it doesn't exist
init_progress_file() {
    if [[ ! -f "$PROGRESS_FILE" ]]; then
        cat > "$PROGRESS_FILE" << 'EOF'
## Codebase Patterns

(Add reusable patterns discovered during implementation here)

---

EOF
        log_info "Created progress.txt"
    fi
}

# Main loop
run_ralph() {
    log_info "Starting Ralph for HRTY (iOS)"
    log_info "Max iterations: $MAX_ITERATIONS"
    log_info "Project directory: $PROJECT_DIR"
    echo ""

    archive_if_branch_changed
    init_progress_file

    for ((i=1; i<=MAX_ITERATIONS; i++)); do
        log_info "=========================================="
        log_info "Iteration $i of $MAX_ITERATIONS"
        log_info "=========================================="
        echo ""

        # Run Claude Code with the prompt
        # Using --print for non-interactive mode and --dangerously-skip-permissions for automation
        local output
        output=$(cd "$PROJECT_DIR" && cat "$PROMPT_FILE" | claude --print --dangerously-skip-permissions 2>&1) || true

        echo "$output"
        echo ""

        # Check for completion signal
        if echo "$output" | grep -q "<promise>COMPLETE</promise>"; then
            log_success "=========================================="
            log_success "All stories complete!"
            log_success "=========================================="
            exit 0
        fi

        # Check for errors that should stop the loop
        if echo "$output" | grep -qi "error\|fatal\|failed"; then
            log_warning "Potential error detected in output"
        fi

        if [[ $i -lt $MAX_ITERATIONS ]]; then
            log_info "Iteration $i complete. Pausing before next iteration..."
            sleep 2
        fi
    done

    log_warning "=========================================="
    log_warning "Max iterations reached without completion"
    log_warning "Check progress.txt for details"
    log_warning "=========================================="
    exit 1
}

# Run the main loop
run_ralph
