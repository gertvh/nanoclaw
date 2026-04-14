---
name: weekly-prep-fetcher
description: Fetch calendar events, emails, and attachments from all configured data sources. Use when scheduled task triggers data collection, or when user asks to "fetch data", "refresh", or "get latest".
---

# Weekly Prep Data Fetcher

You have access to a Python data fetcher at `/workspace/extra/prep-agent/`. This fetcher gathers data from Google Calendar, Gmail, and Microsoft Graph API.

## How to invoke

Run the fetcher via bash:

```bash
cd /workspace/extra/prep-agent && python -m src.main --data-dir /workspace/group/data --accounts-dir /workspace/extra/prep-agent/accounts --account $ACCOUNT_NAME --mode $MODE
```

Where:
- `$ACCOUNT_NAME` is the account this group serves (set in the group's CLAUDE.md)
- `$MODE` is one of:
  - `full` — re-fetch last 14 days (use for weekly Sunday fetch)
  - `incremental` — only new data since last fetch (use for daily/ad-hoc)
  - `range` — specific date range (add `--start YYYY-MM-DD --end YYYY-MM-DD`)

## After fetching

1. Read the fetch results from stdout
2. Report to the user via `mcp__nanoclaw__send_message`:
   - Number of calendar events found
   - Number of emails fetched
   - Number of attachments downloaded
   - Any errors encountered
3. If this was a scheduled fetch, trigger the review skill to analyze the data

## Scheduled task script

For scheduled tasks, use this pre-check script that returns whether to wake the agent:

```bash
#!/bin/bash
cd /workspace/extra/prep-agent
result=$(python -m src.main --data-dir /workspace/group/data --accounts-dir /workspace/extra/prep-agent/accounts --account $ACCOUNT_NAME --mode $MODE 2>&1)
exit_code=$?
if [ $exit_code -eq 0 ]; then
    echo "{\"wakeAgent\": true, \"data\": {\"fetchResult\": \"$result\"}}"
else
    echo "{\"wakeAgent\": true, \"data\": {\"error\": \"$result\"}}"
fi
```
