---
name: task-manager
description: Manage tasks — accept, update, complete, skip, list. Use when user sends task commands like "done 2", "yes 1 3", "skip 2", "tasks", "add task", or updates task status.
---

# Task Manager

Handle task CRUD operations via Telegram messages.

## Task file location
`/workspace/group/data/$ACCOUNT_NAME/tasks.json`

## User commands

Parse these commands from user messages:

| Command | Action |
|---------|--------|
| `tasks` or `list` | Show all open tasks |
| `done N` | Mark task N as done |
| `skip N` | Mark task N as skipped |
| `yes N [M ...]` or `accept N` | Accept suggested task(s) |
| `all` | Accept all suggested tasks |
| `N: context text` | Add a note to task N |
| `add task: description` | Create a new user task |
| `block N` | Mark task N as blocked |
| `unblock N` | Mark task N as open again |

## Task numbering

Tasks are numbered dynamically in the order they're displayed (not by ID). When listing tasks, assign sequential numbers. Keep a mapping of display-number → task-id for the current session.

## Display format

```
📋 Tasks — {account label}

⚡ High priority:
1. [open] Prepare for OVAM sync (due: Tue 13:00)
2. [in-progress] Reply to Peter about OKRs

📋 Medium:
3. [open] Follow up on Peppol/Horus
4. [open] Review architecture doc

📬 Suggested:
S1. Reply to Edward about pricing
S2. Research competitor analysis

✅ Recently completed:
- Submit proposal (done Apr 14)
```

## After each update
Confirm the action: "Marked 'Follow up on Peppol/Horus' as done ✓"

Save updated tasks to tasks.json after every change.
