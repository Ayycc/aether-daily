---
name: loop
description: Refresh Aether Daily articles on a daily schedule at 00:00. Use when the user runs /loop or asks to schedule, automate, or refresh the newspaper feed daily at midnight.
disable-model-invocation: true
metadata:
  schedule: "0 0 * * *"
  timezone: UTC
---

# /loop — Daily Article Refresh

Refresh the Aether Daily front page by updating `data/articles.json` every day at **00:00**.

## When to Use

- User runs `/loop`
- User asks for daily article refresh at midnight
- GitHub Actions or a local daemon should rotate the hero story and bump engagement

## Quick Start

Run one refresh immediately:

```bash
node scripts/refresh-articles.mjs
```

Start the local midnight loop (runs in background, refreshes at 00:00 UTC):

```bash
bash .cursor/skills/loop/scripts/run-loop.sh start
```

Check status or stop:

```bash
bash .cursor/skills/loop/scripts/run-loop.sh status
bash .cursor/skills/loop/scripts/run-loop.sh stop
```

Use a local timezone for midnight (example: US Eastern):

```bash
LOOP_TIMEZONE=America/New_York bash .cursor/skills/loop/scripts/run-loop.sh start
```

## What Each Refresh Does

1. Loads `data/articles.json`
2. Skips if already refreshed today (use `--force` to override)
3. Rotates the front-page hero to the highest-engagement story
4. Bumps like counts and re-stamps timestamps for the new edition
5. Optionally pulls trending posts from X when `X_BEARER_TOKEN` is set
6. Appends a line to `loop/state.md`

## Agent Workflow

When `/loop` is invoked:

1. Run `node scripts/refresh-articles.mjs --force` once to verify the pipeline
2. Confirm `data/articles.json` has a new `lastRefreshed` timestamp and incremented `edition`
3. If the user wants persistent scheduling in CI, rely on `.github/workflows/daily-article-refresh.yml` (00:00 UTC cron)
4. If the user wants a local daemon while developing, start `run-loop.sh start`
5. Append results to `loop/state.md` — never overwrite that file
6. Commit and push when running from automation

## Verification

```bash
node scripts/refresh-articles.mjs --force
node -e "const f=require('./data/articles.json'); console.log(f.edition, f.lastRefreshed, f.articles.find(a=>a.isHero)?.headline)"
```

Expected: edition increments, `lastRefreshed` is today, exactly one article has `"isHero": true`.

## Optional: Live X Data

Set `X_BEARER_TOKEN` in the environment to merge up to three recent high-engagement AI posts from the X API v2 search endpoint during each refresh.

## Production Schedule

GitHub Actions runs the same refresh script daily at **00:00 UTC** and commits changes to `main` when the feed updates.

For always-on cloud scheduling without a local machine, prefer the GitHub Action or Cursor Automations over a local `/loop` daemon.
