# hand — Session Handoff Plugin

Three skills for structured project handoff across Claude Code sessions.

## Skills

| Command | When to use |
|---|---|
| `/hand:on` | Start of session — orient, sync doob, triage and act on open items |
| `/hand:off` | End of session — update HANDOFF.yaml, write .ctx/, sync doob, commit |
| `/hand:over` | On demand — generate visual report + Mermaid diagrams in .ctx/HANDOVER.md |

## File Layout

| File | Location | Committed | Purpose |
|---|---|---|---|
| `HANDOFF.<project>.<base>.yaml` | repo root | yes | Tasks, items, log — doob source of truth |
| `.ctx/HANDOFF.state.yaml` | `.ctx/` | no | Project snapshot (build/tests/branch/notes) |
| `.ctx/HANDOFF.md` | `.ctx/` | no | Rendered reference doc (table view) |
| `.ctx/HANDOVER.md` | `.ctx/` | no | Visual report with Mermaid diagrams |

`.ctx/` is fully generated — add it to `.gitignore`. Only `HANDOFF.yaml` is committed.

## Workflow

```
session start → /hand:on  → syncs doob, reviews human-edits, triages P0/P1/P2
 during work  →            → edit HANDOFF.yaml directly for human-edit overrides
  session end → /hand:off → updates yaml, writes .ctx/, syncs doob, commits
   on demand  → /hand:over → writes .ctx/HANDOVER.md with diagrams
```

## HANDOFF.yaml Schema

```yaml
project: <name>
id: <prefix>        # first 7 chars, used for item IDs
updated: <YYYY-MM-DD>

items:
  - id: <prefix>-<n>
    doob_uuid: <uuid>           # written by doob sync
    name: <kebab-slug>          # immutable
    priority: P0 | P1 | P2     # immutable
    status: open | done | parked | blocked
    title: <one-line>           # immutable
    description: <detail>
    files: [<path>]
    completed: <YYYY-MM-DD>     # when status: done
    extra:
      - date: <YYYY-MM-DD>
        type: note | blocker | decision | discovery | escalation | human-edit
        field: <field>          # human-edit only
        value: <value>          # human-edit only
        reviewed: <YYYY-MM-DD>  # stamped by /hand:off after /hand:on surfaces it
        note: <text>

log:
  - date: <YYYY-MM-DD>
    summary: <one-liner>
    commits: [<short-hash>]
```

## .ctx/HANDOFF.state.yaml Schema

Fully overwritten each session. Extend freely with project-specific facts.

```yaml
updated: <YYYY-MM-DD>
branch: <git branch>
build: clean | failing | unknown
tests: "<N passing>" | "failing: N" | "unknown"
notes: <one-line or null>
```

## Priority Guide

| Priority | Meaning | /hand:on action |
|---|---|---|
| P0 | Broken, blocked, security | Validate + report, ask before acting |
| P1 | Known fix, clear scope | Execute autonomously |
| P2 | Safe to delegate | Dispatch to subagents (cap 5) |

## human-edit Override

To override a field and have it win over doob on next sync, add a `human-edit` extra entry:

```yaml
extra:
  - date: 2026-04-04
    type: human-edit
    field: status
    value: done
    note: "merged out of band"
```

- `/hand:on` surfaces unreviewed human-edits before P0 triage ("Review on Wake")
- `/hand:off` stamps `reviewed: <today>` after user acknowledges
- `/hand:over` marks affected rows with `*` in the items table

## doob Sync

```bash
doob handoff sync --file HANDOFF.<project>.<base>.yaml
```

- doob wins on `status` conflicts — except when an unreviewed `human-edit` entry exists
- New items get `doob_uuid` written back on first sync
- `extra` entries merged bidirectionally

## /hand:over Flags

```
/hand:over                          # full report + all diagrams
/hand:over --report                 # prose summary only
/hand:over --diagrams               # diagrams only
/hand:over --items                  # item table + flowchart
/hand:over --log                    # log + sequence diagram
/hand:over path/to/HANDOFF.*.yaml   # explicit file (must match naming pattern)
```

Generates up to 5 Mermaid diagrams: flowchart (item flow), stateDiagram (status machine),
sequenceDiagram (session timeline), erDiagram (item-file relationships), quadrantChart
(priority/status matrix, ≥6 items only).

## Requirements

- `handoff-detect` on PATH (resolves HANDOFF.yaml for current repo)
- `doob` on PATH for sync steps (skipped gracefully if absent)
