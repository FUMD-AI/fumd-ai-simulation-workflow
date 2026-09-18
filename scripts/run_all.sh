#!/bin/bash
# run_all.sh — Run multiple OMNeT++ simulation configs consecutively
# Place next to run.sh and make executable: chmod +x run_all.sh
#
# Usage:
#   ./run_all.sh VoipDl_900_1 VoipDl_900_2 VoipDl_900_3
#   ./run_all.sh VoipDl_900_1:0 VoipDl_900_1:1 VoipDl_900_2:0
#
# Each config runs sequentially. Output is logged to ./logs/<config>_run<N>.log
# A summary is printed at the end with pass/fail status and elapsed time.
# Exit code is non-zero if any run failed.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN_SCRIPT="$SCRIPT_DIR/run.sh"
LOG_DIR="$SCRIPT_DIR/logs"

# ── Validation ────────────────────────────────────────────────────────────────

if [[ ! -x "$RUN_SCRIPT" ]]; then
    echo "ERROR: run.sh not found or not executable at $RUN_SCRIPT"
    exit 1
fi

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 CONFIG[:RUN] [CONFIG[:RUN] ...]"
    echo "  e.g. $0 VoipDl_900_1 VoipDl_900_2"
    echo "  e.g. $0 VoipDl_900_1:0 VoipDl_900_1:1 VoipDl_900_2:0"
    exit 1
fi

mkdir -p "$LOG_DIR"

# ── Run loop ──────────────────────────────────────────────────────────────────

declare -a RESULTS=()
FAILED=0
TOTAL=$#
COUNT=0

for ARG in "$@"; do
    COUNT=$((COUNT + 1))

    # Parse CONFIG:RUN or CONFIG (default run = 0)
    if [[ "$ARG" == *:* ]]; then
        CONFIG="${ARG%%:*}"
        RUN="${ARG##*:}"
    else
        CONFIG="$ARG"
        RUN="0"
    fi

    LOG_FILE="$LOG_DIR/${CONFIG}_run${RUN}.log"
    LABEL="[$COUNT/$TOTAL] $CONFIG (run $RUN)"

    echo ""
    echo "════════════════════════════════════════════════════════"
    echo "  Starting : $LABEL"
    echo "  Log      : $LOG_FILE"
    echo "  Time     : $(date '+%Y-%m-%d %H:%M:%S')"
    echo "════════════════════════════════════════════════════════"

    START_TS=$(date +%s)

    # Run and capture exit code without aborting the outer script
    set +e
    "$RUN_SCRIPT" "$CONFIG" "$RUN" 2>&1 | tee "$LOG_FILE"
    EXIT_CODE=${PIPESTATUS[0]}
    set -e

    END_TS=$(date +%s)
    ELAPSED=$((END_TS - START_TS))
    ELAPSED_FMT=$(printf '%dh %02dm %02ds' $((ELAPSED/3600)) $((ELAPSED%3600/60)) $((ELAPSED%60)))

    if [[ $EXIT_CODE -eq 0 ]]; then
        STATUS="PASS"
        echo "  ✓ Completed in $ELAPSED_FMT"
    else
        STATUS="FAIL (exit $EXIT_CODE)"
        FAILED=$((FAILED + 1))
        echo "  ✗ Failed after $ELAPSED_FMT (exit code $EXIT_CODE)"
    fi

    RESULTS+=("$STATUS | $LABEL | $ELAPSED_FMT | $LOG_FILE")
done

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════════════════════"
echo "  SUMMARY — $((TOTAL - FAILED))/$TOTAL runs succeeded"
echo "════════════════════════════════════════════════════════"
printf "  %-6s | %-40s | %-12s | %s\n" "Status" "Config (run)" "Elapsed" "Log"
printf "  %-6s-+-%-40s-+-%-12s-+-%s\n" "------" "----------------------------------------" "------------" "---"
for RESULT in "${RESULTS[@]}"; do
    printf "  %s\n" "$RESULT"
done
echo ""

if [[ $FAILED -gt 0 ]]; then
    echo "  $FAILED run(s) failed. Check logs above for details."
    exit 1
else
    echo "  All runs completed successfully."
    exit 0
fi
