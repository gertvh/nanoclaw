---
name: weekly-review
description: Analyze fetched data and generate a smart weekly prep with prioritized tasks. Use when user asks to "review my week", after Sunday data fetch completes, or on any "prep" request.
---

# Weekly Review

Analyze the fetched context data and produce a smart weekly preparation with tasks and briefs.

## Data locations

- Context: `/workspace/group/data/$ACCOUNT_NAME/context/`
  - `calendar.json` — merged calendar events
  - `meetings/` — per-meeting context markdown
  - `emails/` — per-attendee email history
  - `documents/` — attachments and text extractions
- Knowledge: `/workspace/extra/prep-agent/accounts/$ACCOUNT_NAME/knowledge.md`
- Tasks: `/workspace/group/data/$ACCOUNT_NAME/tasks.json`
- History: `/workspace/group/data/$ACCOUNT_NAME/history/`
- Account context: `/workspace/extra/prep-agent/accounts/$ACCOUNT_NAME/system-prompt.md`

## Your process

### Step 1: Read all context
Read calendar.json, all meeting context files, email context files, documents, knowledge.md, and existing tasks.

### Step 2: Create/update tasks
Using the Python task model:
```bash
cd /workspace/extra/prep-agent && python -c "
from src.tasks import load_tasks, save_tasks, create_task, get_open_tasks
from src.suggestions import suggest_tasks_from_emails
import json

tasks = load_tasks('/workspace/group/data/$ACCOUNT_NAME/tasks.json')
calendar = json.loads(open('/workspace/group/data/$ACCOUNT_NAME/context/calendar.json').read())
# Add suggestion logic here
"
```

Or create tasks by writing directly to tasks.json — the format is:
```json
{
  "id": "xx-YYYYMMDD-abcdef",
  "type": "meeting-prep|deliverable|action-item|follow-up|reply-needed|review|research|question|deadline",
  "title": "Task title",
  "status": "suggested|open|in-progress|done|skipped|blocked",
  "priority": "high|medium|low",
  "due": "ISO datetime or null",
  "source": "where you found this",
  "account": "account name",
  "description": "details",
  "related": [],
  "auto_dismiss_after": "ISO datetime or null",
  "notes": [{"ts": "ISO", "by": "agent|gert|system", "text": "note"}],
  "created": "ISO datetime",
  "updated": "ISO datetime"
}
```

### Step 3: Post summary to Telegram
Use `mcp__nanoclaw__send_message` to post:

1. **Open tasks** grouped by priority:
   ```
   📋 Your week — {account label}

   ⚡ High priority:
   1. Prepare for OVAM sync (Tue 13:00) — no email context, what should I focus on?
   2. Reply to Peter — asked about OKR KR3 revision (4 days ago)

   📋 Medium:
   3. Follow up on Peppol/Horus with Vadecas
   4. Review attached architecture doc from Ilse

   📬 Suggested (accept with 'yes N'):
   S1. Research: competitor pricing mentioned by Edward
   ```

2. **Targeted questions** where you need more context

### Step 4: Wait for user interaction
The user will reply to:
- Accept/skip suggestions: "yes 1 3", "skip 2", "all"
- Update tasks: "done 2", "1: focus on data model review"
- Ask for deeper analysis: "go deeper on 1"
- Request deliverable drafts: "draft outline for task 3"

Process each reply and update tasks accordingly.

### Step 5: Generate briefs
When the user says "looks good", "generate briefs", or similar:
1. Write `week-overview.md` to the output directory
2. Write per-meeting briefs to `output/meeting-briefs/`
3. Write deliverable outlines to `output/deliverables/`
4. Write `time-blocks.md`
5. Update knowledge.md with this week's key takeaways

## Tone
- Be direct and practical
- Flag uncertainty
- Prioritize actionable items
- When you infer something, say where you got it from
