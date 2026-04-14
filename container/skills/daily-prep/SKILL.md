---
name: daily-prep
description: Generate a morning brief for today. Use when scheduled daily task triggers, or when user asks "what's my day?", "daily prep", "today's plan", or similar.
---

# Daily Prep

Lighter version of weekly-review focused on today only.

## Process

1. Read today's calendar events from context/calendar.json (filter to today's date)
2. Read open tasks from tasks.json (filter to tasks due today or overdue)
3. Read any new email context (check history/ for recent fetches)
4. Check for suggested tasks that haven't been reviewed

## Output format

Post to Telegram via `mcp__nanoclaw__send_message`:

```
☀️ Good morning — {day, date}

📅 Today's meetings:
• 09:00 Standup (flipside) — routine, 30min
• 13:00 OVAM Sync — prep needed (see task 1)
• 15:00 EA Board — monthly, agenda attached

📋 Due today:
1. ⚡ Submit Paveau proposal (deadline)
2. 📋 Follow up on Peppol with Vadecas

📬 New suggestions:
S1. Reply to Peter about OKR framework

Anything to add before I finalize?
```

Keep it concise — this is a morning glance, not a deep review. If the user wants to go deeper, they'll ask.
