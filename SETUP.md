# NanoClaw Weekly Prep Agent — Setup Guide

## Overview

This sets up NanoClaw as the agent runtime for the weekly prep system. NanoClaw connects to Telegram, runs agents in isolated Docker containers, and uses the Python data fetcher from `personal-assistant/` for gathering data.

## Prerequisites

- Proxmox LXC container (or any Linux box) with:
  - Node.js 22+
  - Docker
  - Python 3.11+ (for the data fetcher)
  - Claude Code CLI installed and authenticated (Max subscription)
  - tmux (for deep mode interactive sessions)
- Telegram bot token (already created: see personal-assistant/.env)
- Anthropic API key (for NanoClaw's agent — separate from Max subscription)

## Step 1: NanoClaw base setup

```bash
cd /home/gert/projects/nanoclaw-prep
claude
# In the Claude Code session, run: /setup
```

The `/setup` skill walks you through:
1. Node.js + dependency installation
2. Docker setup and container build
3. Credential system (OneCLI for API key management)
4. Timezone configuration (set to Europe/Brussels)

## Step 2: Add Telegram channel

In the Claude Code session:
```
/add-telegram-swarm
```

This will ask for your Telegram bot token. Use the one from your `.env`:
```
8645269519:AAHIswV585jJwBOJbuL4R49rszUSZUqEqzM
```

Follow the prompts to complete Telegram setup.

## Step 3: Configure mount allowlist

Copy the mount configuration to allow containers to access the prep agent code:

```bash
mkdir -p ~/.config/nanoclaw
cp prep-agent/mount-config.json ~/.config/nanoclaw/mount-allowlist.json
```

This allows NanoClaw containers to read/write to `/home/gert/projects/personal-assistant/` (the Python fetcher and account configs).

## Step 4: Register account groups

Start the NanoClaw service and register two Telegram groups:

### Create Telegram groups
1. Open Telegram
2. Create a new group: "flipside-prep" — add your bot to it
3. Create a new group: "dv-prep" — add your bot to it
4. In each group, disable Group Privacy for the bot (via BotFather: /setprivacy → Disable)

### Register groups via main channel
In your main/personal chat with the bot:
```
@Andy register flipside-prep as flipside
@Andy register dv-prep as digitaal-vlaanderen
```

### Set up group CLAUDE.md
After registration, copy the prepared templates:

```bash
# Find the group folders (registered groups appear under groups/)
ls groups/

# Copy templates
cp prep-agent/templates/group-flipside.md groups/flipside-prep/CLAUDE.md
cp prep-agent/templates/group-dv.md groups/dv-prep/CLAUDE.md
```

## Step 5: Install Python dependencies in containers

The container needs Python + the prep agent dependencies. You have two options:

### Option A: Modify the Dockerfile (recommended)
Add to `container/Dockerfile` before the final `USER node` line:

```dockerfile
# Install Python for prep agent
RUN apt-get update && apt-get install -y python3 python3-pip python3-venv && rm -rf /var/lib/apt/lists/*
```

Then rebuild: `./container/build.sh`

### Option B: Install at runtime
Each container would install dependencies on startup. Slower but doesn't require Dockerfile changes. Not recommended for regular use.

## Step 6: Set up scheduled tasks

In the flipside-prep Telegram group, tell the agent:

```
Schedule a weekly data fetch every Sunday at 20:00 Europe/Brussels.
Run the script at /workspace/extra/prep-agent/scripts/fetch-weekly.sh
with environment variable ACCOUNT_NAME=flipside.
After the fetch, do a weekly review.
```

```
Schedule a daily morning prep every weekday at 07:00 Europe/Brussels.
Run the script at /workspace/extra/prep-agent/scripts/fetch-daily.sh
with environment variable ACCOUNT_NAME=flipside.
After the fetch, give me a daily brief.
```

Do the same in the dv-prep group, replacing `flipside` with `digitaal_vlaanderen`.

## Step 7: Configure environment

Create/update `.env` in the nanoclaw-prep directory:

```bash
# NanoClaw core
ASSISTANT_NAME=Prep
TZ=Europe/Brussels
CONTAINER_TIMEOUT=3600000
MAX_CONCURRENT_CONTAINERS=2

# Telegram
TELEGRAM_BOT_TOKEN=8645269519:AAHIswV585jJwBOJbuL4R49rszUSZUqEqzM

# Anthropic (for agent API calls — separate from Max subscription)
ANTHROPIC_API_KEY=your-anthropic-api-key
```

For the Python fetcher, the existing `.env` in `personal-assistant/` is used (mounted into containers).

## Step 8: Test the setup

1. Send a message in the flipside-prep Telegram group: "fetch data"
2. The agent should invoke the data fetcher and report results
3. Send: "review my week"
4. The agent should analyze context and post a task summary
5. Try: "tasks" to see the task list
6. Try: "done 1" to mark a task complete
7. Try: "go deeper on task 2" to test deep mode

## Architecture overview

```
Telegram messages
  ↓
NanoClaw (Node.js host)
  ↓
Docker container per group
  ├── Claude Agent SDK (Anthropic API)
  ├── Container skills (SKILL.md instructions)
  ├── Python fetcher (mounted from personal-assistant/)
  ├── Group CLAUDE.md (per-account context)
  └── Group data directory
       ├── context/ (calendar, emails, meetings, documents)
       ├── tasks.json
       ├── history/
       └── output/

Deep mode:
  Docker container → claude CLI (Max subscription) → tmux session
```

## Troubleshooting

### Bot doesn't respond
- Check NanoClaw service is running: `systemctl --user status nanoclaw`
- Check logs: `tail -f logs/nanoclaw.log`
- Verify Telegram bot token is correct
- Ensure Group Privacy is disabled for the bot

### Data fetch fails
- Check Python venv is installed in container
- Verify `.env` credentials (Graph API, Google OAuth)
- Check mount allowlist includes personal-assistant directory

### Deep mode doesn't work
- Verify `claude` CLI is installed and authenticated on the host
- Check `tmux` is available
- Ensure the container can access the host's claude binary

### Container won't start
- Check Docker is running: `docker info`
- Rebuild container: `./container/build.sh`
- Check logs: `docker logs nanoclaw-<group>-<timestamp>`
