---
name: deep-mode
description: Escalate to Claude Code CLI for complex analysis or interactive sessions. Use when user says "go deeper on X", "deep dive", "open deep session", or when a task needs more capability than the agent can provide.
---

# Deep Mode

Escalate to Claude Code CLI (uses Max subscription) for tasks that need deeper analysis, document drafting, or interactive exploration.

## Two variants

### Variant A: Headless (default)
Triggered by: "go deeper on {X}", "analyze {X} in detail", "deep dive on {X}"

```bash
# Build system prompt from account context
ACCOUNT_DIR="/workspace/extra/prep-agent/accounts/$ACCOUNT_NAME"
DATA_DIR="/workspace/group/data/$ACCOUNT_NAME"

# Create temp system prompt
cat "$ACCOUNT_DIR/system-prompt.md" > /tmp/deep-prompt.md
echo "" >> /tmp/deep-prompt.md
echo "## Current context" >> /tmp/deep-prompt.md
echo "Data directory: $DATA_DIR" >> /tmp/deep-prompt.md
echo "Knowledge file: $ACCOUNT_DIR/knowledge.md" >> /tmp/deep-prompt.md

# Run headless
claude -p "$USER_REQUEST. Read context from $DATA_DIR/context/ and knowledge from $ACCOUNT_DIR/knowledge.md. Write any output to $DATA_DIR/output/" \
  --system-prompt /tmp/deep-prompt.md \
  --allowedTools "Read,Write,mcp__*"
```

After completion:
1. Capture the output
2. Post a summary to Telegram via `mcp__nanoclaw__send_message`
3. Create a task for any deliverable produced
4. Save any generated files to the data directory

### Variant B: Interactive
Triggered by: "open deep session for {X}", "interactive session", "I want to work on this interactively"

```bash
# Same system prompt setup as Variant A, then:
SESSION_NAME="deep-$ACCOUNT_NAME-$(date +%s)"

tmux new-session -d -s "$SESSION_NAME" \
  "claude --system-prompt /tmp/deep-prompt.md --allowedTools 'Read,Write,mcp__*'"

echo "Deep session ready. Attach with: tmux attach -t $SESSION_NAME"
```

Post to Telegram: "Deep session '$SESSION_NAME' is ready. Run `tmux attach -t $SESSION_NAME` on your server to start."

After the user detaches/exits:
1. Check for new/modified files in the data directory
2. Post summary of changes to Telegram
3. Create tasks for any deliverables

## When to suggest deep mode

If you encounter a task that requires:
- Multi-file analysis or research
- Complex document drafting
- Architecture analysis
- Code review or generation
- Anything beyond a quick text response

Say: "This might benefit from a deeper analysis. Want me to go deeper on this? (headless) or open an interactive session?"

## Important
- Deep mode uses `claude` CLI which runs on the Max subscription — no API cost
- Each deep session is per-account (strict isolation)
- MCP servers from the account config can be passed to the deep session
