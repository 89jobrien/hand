---
name: onboard
description: Use when the user says "onboard me", "set up hand", "what does hand do", "walk me
  through setup", or invokes /hand:onboard. Guides through installation, verification, and first
  use of the hand session handoff plugin.
---

# onboard — hand plugin setup

## Overview

**hand** provides three skills for structured project handoff across Claude Code sessions:

| Skill | When |
|-------|------|
| `/hand:on` | Session start — triage open items, act on P1s, surface human-edits |
| `/hand:off` | Session end — update HANDOFF.yaml, write .ctx/, sync SQLite, commit |
| `/hand:over` | On demand — generate visual report + Mermaid diagrams |

## Step 1: Prerequisites

```bash
which claude sqlite3 handoff-detect
```

- `claude` — Claude Code CLI (required)
- `sqlite3` — local status DB (required; ships with macOS)
- `handoff-detect` — resolves HANDOFF.yaml for current repo (install from atelier tooling)

If `handoff-detect` is missing, `hand` falls back to globbing `HANDOFF.*.yaml` at repo root.

## Step 2: Clone and Init

```bash
git clone https://github.com/89jobrien/hand ~/dev/hand
cd ~/dev/hand
just init
```

`just init` will:
1. Set `core.hooksPath = .githooks` so the post-commit hook auto-reinstalls on source changes
2. Register the local plugin marketplace
3. Install the plugin via `claude plugin install hand@local`

If `just` is not installed: `brew install just`.

If the local marketplace is not set up yet, install directly:

```bash
claude plugin install /path/to/hand
```

## Step 3: Smoke Test

In a new Claude session, run `/hand:on` in any git repo. Expected output:

```
## Handoff Triage — <repo>

No HANDOFF file found. Run /hand:off at session end to create one.
```

Or, if a HANDOFF.yaml exists, it surfaces items by priority.

## Step 4: Create Your First Handoff

At the end of a session, run `/hand:off`. It will:
1. Read git log and current state
2. Write `HANDOFF.<project>.<base>.yaml` at repo root
3. Write `.ctx/HANDOFF.state.yaml` (build/tests/branch)
4. Upsert items to `~/.local/share/atelier/handoff.db`
5. Commit `HANDOFF.yaml`

## Step 5: Visualize

Run `/hand:over` to generate `.ctx/HANDOVER.md` with Mermaid diagrams.
Requires `uv` and `pyyaml` for the diagram script (falls back to inline generation).

## Onboarding Complete

> Run `/hand:on` at every session start. Run `/hand:off` before closing.
> HANDOFF.yaml is committed; `.ctx/` is never committed.
