#!/bin/bash
#
# Run all remaining features sequentially (unattended overnight run)
# Usage: caffeinate -i ./scripts/run-all-features.sh
#
# IMPORTANT: Run with 'caffeinate -i' to prevent Mac from sleeping
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[Auto]${NC} $(date '+%H:%M:%S') $1"; }
success() { echo -e "${GREEN}[Auto]${NC} $(date '+%H:%M:%S') $1"; }
warn() { echo -e "${YELLOW}[Auto]${NC} $(date '+%H:%M:%S') $1"; }
error() { echo -e "${RED}[Auto]${NC} $(date '+%H:%M:%S') $1"; }

# All features to process
FEATURES=(
    "008-symptom-alert"
    "009-weight-chart"
    "010-symptom-trends"
    "011-pdf-export"
    "012-settings"
    "013-healthkit-weight"
    "014-healthkit-heartrate"
    "015-daily-reminder"
    "016-onboarding"
    "017-medication-photo"
    "018-dizziness-bp-prompt"
)

run_feature() {
    local FEATURE_ID="$1"

    log "=========================================="
    log "Starting feature: $FEATURE_ID"
    log "=========================================="

    # Check if specs exist
    if [[ ! -d "specs/$FEATURE_ID" ]]; then
        error "Specs not found for $FEATURE_ID, skipping"
        return 1
    fi

    # Create branch from main
    git checkout main
    git checkout -b "$FEATURE_ID" 2>/dev/null || git checkout "$FEATURE_ID"

    # Run the persona loop (max 25 iterations)
    if ./scripts/ralph-persona.sh "$FEATURE_ID" 25; then
        success "Feature $FEATURE_ID completed successfully"

        # Push feature branch
        git push origin "$FEATURE_ID" || warn "Push failed for $FEATURE_ID"

        # Merge to main
        git checkout main
        git merge "$FEATURE_ID" -m "Merge $FEATURE_ID into main"
        git push origin main || warn "Push main failed"

        return 0
    else
        error "Feature $FEATURE_ID failed or hit max iterations"
        git checkout main
        return 1
    fi
}

# Main execution
log "=========================================="
log "HRTY Overnight Feature Run"
log "=========================================="
log "Features to process: ${#FEATURES[@]}"
log ""

COMPLETED=0
FAILED=0

for FEATURE in "${FEATURES[@]}"; do
    if run_feature "$FEATURE"; then
        ((COMPLETED++))
    else
        ((FAILED++))
    fi

    log "Progress: $COMPLETED completed, $FAILED failed"
    log ""
done

log "=========================================="
success "Overnight run complete!"
success "Completed: $COMPLETED / ${#FEATURES[@]}"
if [[ $FAILED -gt 0 ]]; then
    warn "Failed: $FAILED"
fi
log "=========================================="
