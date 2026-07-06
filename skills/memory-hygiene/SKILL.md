---
name: memory-hygiene
description: Use when auditing, cleaning, or reorganizing Claude Code auto-memory directories, when memories contradict reality or each other, when a project has moved or been renamed, or when MEMORY.md index lines don't match the files on disk.
---

# Memory Hygiene

## Overview

Auto-memory is keyed to the exact directory a session launches from (`~/.claude/projects/<sanitized-cwd>/memory/`). A memory can be perfectly written and still **dead** — parked at a cwd nobody launches from. Audit reachability first, content second.

## Procedure

1. **Reachability first.** For every memory dir, decode its name back to a cwd (`-Users-akashsuryavanshi-Projects-Foo` → `~/Projects/Foo`) and check that the directory exists and is where the project actually lives now. A dir keyed to a dead or moved cwd is orphaned **even if its contents are flawless** — merge it into the dir for the project's current path (create it if needed), then retire the orphan. Two dirs for one project = a split pair: the live one is where the project resides today; port unique content from the other, then retire it.
2. **Index sync.** Every MEMORY.md line resolves to a file; every memory file has a line. Fix both directions.
3. **Contradictions.** When two memories disagree, the more recent, more specific one wins; update or retire the loser the moment you spot it — never leave both standing.
4. **Stray files.** A MEMORY.md at a project-dir root (outside `memory/`) is never loaded — fold anything unique into the real index and remove it.
5. **Archive, don't delete.** Anything retired moves to `~/.claude/backups/<date>/memory-archive/`, never `rm`. Durable rules (safety constraints, hard-won gotchas, `type: feedback`) must survive every merge.
6. **Retire dirs only for dead cwds.** A dir whose cwd still exists stays, even if you moved some of its content elsewhere — hub dirs (like `~/Projects` itself) legitimately hold cross-project and user-level memories that belong to no single project.

## Done means

Every memory dir maps to a real, current cwd; every index resolves both ways; no two memories contradict; nothing durable was lost (it's indexed at the live path or archived, never gone).
