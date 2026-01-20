#!/bin/bash
#
# Ralph Multi-Persona Review Loop for Claude Code
# Cycles through 6 expert personas to review and improve a feature
#
# Usage: ./scripts/ralph-persona.sh <feature-id> [max_iterations]
# Example: ./scripts/ralph-persona.sh 001-example-feature 25
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Arguments
FEATURE_ID="${1:-}"
MAX_ITERATIONS="${2:-25}"

# Files
PROMPT_TEMPLATE="$PROJECT_DIR/prompt-persona.md"
ITERATION_FILE="$PROJECT_DIR/.ralph-iteration"
SPECS_DIR="$PROJECT_DIR/specs/$FEATURE_ID"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Persona names for display
PERSONAS=("CODE_REVIEWER" "SYSTEM_ARCHITECT" "FRONTEND_DESIGNER" "QA_ENGINEER" "PROJECT_MANAGER" "BUSINESS_ANALYST")

log_info() { echo -e "${BLUE}[Ralph]${NC} $1"; }
log_success() { echo -e "${GREEN}[Ralph]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[Ralph]${NC} $1"; }
log_error() { echo -e "${RED}[Ralph]${NC} $1"; }
log_persona() { echo -e "${CYAN}[Persona]${NC} $1"; }

# Validate arguments
if [[ -z "$FEATURE_ID" ]]; then
    log_error "Usage: $0 <feature-id> [max_iterations]"
    log_info "Example: $0 001-example-feature 25"
    log_info ""
    log_info "Available features:"
    if [[ -d "$PROJECT_DIR/specs" ]]; then
        ls -1 "$PROJECT_DIR/specs" 2>/dev/null | sed 's/^/  - /'
    else
        log_warning "  No specs directory found. Create specs/<feature-id>/"
    fi
    exit 1
fi

# Check specs exist
if [[ ! -d "$SPECS_DIR" ]]; then
    log_error "Specs directory not found: $SPECS_DIR"
    log_info "Create the directory with spec.md and tasks.md"
    exit 1
fi

if [[ ! -f "$SPECS_DIR/tasks.md" ]]; then
    log_error "tasks.md not found in $SPECS_DIR"
    exit 1
fi

if [[ ! -f "$SPECS_DIR/spec.md" ]]; then
    log_error "spec.md not found in $SPECS_DIR"
    exit 1
fi

# Check prompt template exists
if [[ ! -f "$PROMPT_TEMPLATE" ]]; then
    log_error "Prompt template not found: $PROMPT_TEMPLATE"
    exit 1
fi

# Check Claude CLI
if ! command -v claude &> /dev/null; then
    log_error "Claude Code CLI not found. Install from: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

# Get or initialize iteration counter
get_iteration() {
    if [[ -f "$ITERATION_FILE" ]]; then
        local stored_feature=$(head -1 "$ITERATION_FILE" 2>/dev/null || echo "")
        if [[ "$stored_feature" == "$FEATURE_ID" ]]; then
            tail -1 "$ITERATION_FILE" 2>/dev/null || echo "1"
        else
            echo "1"
        fi
    else
        echo "1"
    fi
}

save_iteration() {
    echo "$FEATURE_ID" > "$ITERATION_FILE"
    echo "$1" >> "$ITERATION_FILE"
}

# Get branch name from feature ID
get_branch_name() {
    echo "$FEATURE_ID"
}

# Generate prompt with substitutions
generate_prompt() {
    local iteration=$1
    local branch=$(get_branch_name)

    sed -e "s/{{FEATURE_ID}}/$FEATURE_ID/g" \
        -e "s/{{BRANCH_NAME}}/$branch/g" \
        -e "s/{{ITERATION}}/$iteration/g" \
        "$PROMPT_TEMPLATE"
}

# Track consecutive clean cycles
CLEAN_CYCLES=0
CLEAN_CYCLE_FILE="$PROJECT_DIR/.ralph-clean-cycles"

reset_clean_cycles() {
    echo "0" > "$CLEAN_CYCLE_FILE"
}

increment_clean_cycles() {
    local current=$(cat "$CLEAN_CYCLE_FILE" 2>/dev/null || echo "0")
    echo $((current + 1)) > "$CLEAN_CYCLE_FILE"
}

get_clean_cycles() {
    cat "$CLEAN_CYCLE_FILE" 2>/dev/null || echo "0"
}

# Main loop
run_ralph_persona() {
    local iteration=$(get_iteration)
    local branch=$(get_branch_name)

    log_info "=========================================="
    log_info "Ralph Multi-Persona Review"
    log_info "=========================================="
    log_info "Feature: $FEATURE_ID"
    log_info "Branch: $branch"
    log_info "Max iterations: $MAX_ITERATIONS"
    log_info "Starting at iteration: $iteration"
    echo ""

    # Ensure we're on the right branch
    cd "$PROJECT_DIR"
    local current_branch=$(git branch --show-current 2>/dev/null || echo "")
    if [[ "$current_branch" != "$branch" ]]; then
        log_info "Switching to branch: $branch"
        git checkout "$branch" 2>/dev/null || git checkout -b "$branch"
    fi

    # Initialize clean cycle tracking
    if [[ ! -f "$CLEAN_CYCLE_FILE" ]]; then
        reset_clean_cycles
    fi

    while [[ $iteration -le $MAX_ITERATIONS ]]; do
        local persona_index=$((iteration % 6))
        local persona_name="${PERSONAS[$persona_index]}"

        log_info "=========================================="
        log_info "Iteration $iteration of $MAX_ITERATIONS"
        log_persona "$persona_name"
        log_info "=========================================="
        echo ""

        # Generate the prompt
        local prompt=$(generate_prompt $iteration)

        # Run Claude
        local output
        output=$(echo "$prompt" | claude --print --dangerously-skip-permissions 2>&1) || true

        echo "$output"
        echo ""

        # Check for feature completion
        if echo "$output" | grep -q "<promise>FEATURE_READY</promise>"; then
            log_success "=========================================="
            log_success "FEATURE READY!"
            log_success "All personas report no issues."
            log_success "=========================================="

            # Cleanup
            rm -f "$ITERATION_FILE" "$CLEAN_CYCLE_FILE"
            exit 0
        fi

        # Check if this iteration made changes (look for commit messages)
        if echo "$output" | grep -qiE "no (issues|changes|problems) found|nothing to (fix|improve)|all (good|clear|passing)"; then
            increment_clean_cycles
            local clean=$(get_clean_cycles)
            log_info "Clean iteration. Consecutive clean: $clean/12"

            # If we've had 2 full cycles (12 iterations) with no issues, complete
            if [[ $clean -ge 12 ]]; then
                log_success "=========================================="
                log_success "FEATURE READY! (2 clean cycles)"
                log_success "=========================================="
                rm -f "$ITERATION_FILE" "$CLEAN_CYCLE_FILE"
                exit 0
            fi
        else
            # Reset clean cycle counter if changes were made
            reset_clean_cycles
        fi

        # Save progress
        iteration=$((iteration + 1))
        save_iteration $iteration

        if [[ $iteration -le $MAX_ITERATIONS ]]; then
            log_info "Pausing before next iteration..."
            sleep 2
        fi
    done

    log_warning "=========================================="
    log_warning "Max iterations reached"
    log_warning "Feature may need manual review"
    log_warning "=========================================="
    exit 1
}

# Run it
run_ralph_persona
