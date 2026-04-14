#!/bin/bash
# Scheduled task pre-check script: weekly data fetch
# Runs Sunday 20:00, fetches next week's data for this account
set -euo pipefail

ACCOUNT_NAME="${ACCOUNT_NAME:-unknown}"
PREP_DIR="/workspace/extra/prep-agent"
DATA_DIR="/workspace/group/data"

cd "$PREP_DIR"

result=$(python -m src.main \
    --data-dir "$DATA_DIR" \
    --accounts-dir "$PREP_DIR/accounts" \
    --account "$ACCOUNT_NAME" \
    --mode full 2>&1) || true

exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "{\"wakeAgent\": true, \"data\": {\"action\": \"weekly-review\", \"fetchOutput\": \"$(echo "$result" | tail -5 | tr '\n' ' ')\"}}"
else
    echo "{\"wakeAgent\": true, \"data\": {\"action\": \"report-error\", \"error\": \"$(echo "$result" | tail -3 | tr '\n' ' ')\"}}"
fi
