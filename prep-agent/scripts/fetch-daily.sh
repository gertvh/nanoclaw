#!/bin/bash
# Scheduled task pre-check script: daily data fetch
# Runs daily 07:00, fetches today's data incrementally
set -euo pipefail

ACCOUNT_NAME="${ACCOUNT_NAME:-unknown}"
PREP_DIR="/workspace/extra/prep-agent"
DATA_DIR="/workspace/group/data"

TODAY=$(date +%Y-%m-%d)

cd "$PREP_DIR"

result=$(python -m src.main \
    --data-dir "$DATA_DIR" \
    --accounts-dir "$PREP_DIR/accounts" \
    --account "$ACCOUNT_NAME" \
    --mode incremental 2>&1) || true

exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "{\"wakeAgent\": true, \"data\": {\"action\": \"daily-prep\", \"date\": \"$TODAY\", \"fetchOutput\": \"$(echo "$result" | tail -5 | tr '\n' ' ')\"}}"
else
    echo "{\"wakeAgent\": true, \"data\": {\"action\": \"report-error\", \"error\": \"$(echo "$result" | tail -3 | tr '\n' ' ')\"}}"
fi
