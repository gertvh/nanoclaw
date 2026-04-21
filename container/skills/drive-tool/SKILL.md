---
name: drive-tool
description: Read, search, and write Google Drive — ad-hoc. Use when the user asks to find/read/store documents, proposals, or customer info on Drive, or to create and file a new document (e.g. a proposal) into a specific folder. Supports Google Docs, Sheets, PDFs, and arbitrary files.
---

# Google Drive Tool

You have a Python CLI at `/workspace/extra/prep-agent/` for Drive operations. All output is JSON on stdout.

## When to use

- "Find the proposal for X" / "search for Y on Drive" → `search`
- "Read file Z for context" → `read` (auto-exports Google Docs as markdown, Sheets as CSV, OCRs PDFs)
- "Upload / store this in folder X" → `find-folder` then `upload` (or `create-doc` + `--from-file` if it's a generated proposal)
- "Create a proposal and file it in presales" → `find-folder "presales"` → write markdown to `/tmp/foo.md` → `create-doc --name "..." --folder-id <id> --from-file /tmp/foo.md`
- "List what's in folder X" → `find-folder` + `list --folder-id <id>`

## Invocation pattern

```bash
cd /workspace/extra/prep-agent && python -m src.fetchers.google_drive_cli <subcommand> [args]
```

## Subcommands

| Command | Purpose |
|---|---|
| `list [--folder-id ID] [--limit N]` | List files in root or a folder |
| `search QUERY [--type doc\|sheet\|slide\|folder\|pdf] [--limit N]` | Search by name + fullText |
| `read ID_OR_NAME [--output PATH]` | Read content (auto-exports Docs/Sheets, OCRs PDFs). If the file is binary and no `--output` is given, returns an error with the mimeType. |
| `upload LOCAL_PATH [--folder-id ID] [--name NAME] [--as-doc]` | Upload a file. `--as-doc` converts markdown/docx into a native Google Doc. |
| `create-doc --name NAME [--folder-id ID] [--from-file PATH]` | Create a Google Doc, optionally seeded from a local markdown/text file |
| `mkdir NAME [--parent-id ID]` | Create a folder |
| `find-folder NAME` | Find folder(s) by exact name — returns IDs. Use before upload/move when you only know the folder name. |
| `move FILE_ID FOLDER_ID` | Move a file. Use `root` as folder_id for Drive root. |
| `delete FILE_ID --confirm` | Delete permanently. ALWAYS confirm with the user before calling this. |

## Important rules

1. **Never call `delete` without explicit user confirmation in the current turn.** "Delete X" is enough; "delete everything matching Y" requires showing the list first and asking.
2. **Before `upload` or `move` with a folder name, call `find-folder` first** to get the ID. If it returns zero or multiple matches, ask the user to clarify rather than guessing.
3. **When reading a file, the output can be large.** For Docs/PDFs over ~50k chars, pass `--output /tmp/somefile.md` and then read only what's relevant with `Read` / `Grep` rather than dumping everything into context.
4. **For multi-file context gathering** ("find all info on customer Y"), run `search` first, then read top 3–5 matches by relevance. Don't blindly read every hit.
5. **Proposal creation flow:** draft markdown in `/tmp/proposal-<customer>.md`, then `create-doc --name "<Customer> Proposal <date>" --folder-id <presales-folder-id> --from-file /tmp/proposal-<customer>.md`. Return the `webViewLink` to the user.

## Output

Success: JSON on stdout. Failure: JSON on stderr with `error` key, non-zero exit. If you see `HttpError 403: insufficient permissions`, the OAuth scope may be wrong — report to the user, do not retry.
