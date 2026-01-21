#!/bin/bash
#
# Run all remaining features sequentially (unattended)
# Usage: ./scripts/run-all-features.sh
#
# This script will run through all features without stopping.
# Keep your laptop awake (plugged in, prevent sleep).
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[Auto]${NC} $1"; }
success() { echo -e "${GREEN}[Auto]${NC} $1"; }

# Features to run (add specs inline for each)
run_feature() {
    local FEATURE_ID="$1"
    local PREV_FEATURE="$2"

    log "=========================================="
    log "Starting feature: $FEATURE_ID"
    log "=========================================="

    # Merge previous feature if exists
    if [[ -n "$PREV_FEATURE" ]]; then
        git checkout main
        git merge "$PREV_FEATURE" || true
    fi

    # Create branch
    git checkout -b "$FEATURE_ID" 2>/dev/null || git checkout "$FEATURE_ID"

    # Run the persona loop
    ./scripts/ralph-persona.sh "$FEATURE_ID" 25

    # Push results
    git push origin "$FEATURE_ID" || true
    git push origin main || true

    success "Feature $FEATURE_ID complete!"
}

log "Starting unattended feature run"
log "Keep laptop awake and plugged in"
echo ""

# Run remaining features in order
# (You already have 007 running, this picks up from 008)

# Wait for current feature to finish if running
if pgrep -f "ralph-persona.sh" > /dev/null; then
    log "Waiting for current feature to complete..."
    while pgrep -f "ralph-persona.sh" > /dev/null; do
        sleep 30
    done
fi

# Continue with remaining features
PREV=""
for FEATURE in 008-symptom-alert 009-weight-chart 010-symptom-trends 011-pdf-export 012-settings 013-healthkit-weight 014-healthkit-heartrate 015-daily-reminder 016-onboarding 017-medication-photo 018-dizziness-bp-prompt; do
    # Check if specs exist, if not skip (you'll need to create them)
    if [[ -d "specs/$FEATURE" ]]; then
        run_feature "$FEATURE" "$PREV"
        PREV="$FEATURE"
    else
        log "Skipping $FEATURE - no specs found (create specs/$FEATURE/spec.md and tasks.md)"
    fi
done

success "=========================================="
success "All features complete!"
success "=========================================="
