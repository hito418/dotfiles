---
name: review-pr
description: Work through unresolved review comments on the current PR (GitHub) or MR (GitLab). Triages each comment as relevant or hallucinated/irrelevant, fixes the relevant ones in code, resolves every thread (with a reply explaining skips), and prints a recap. Auto-detects the platform from the git remote. Use when the user says "review pr", "review mr", "address comments", "resolve comments", "process review feedback", or any variation requesting to work through PR/MR review feedback.
allowed-tools: Bash(git *:*), Bash(gh *:*), Bash(glab *:*), Bash(scripts/*:*), Read, Edit, Write, Grep, Glob
model: sonnet
---

# PR / MR Review Response

## Workflow

### 1. List unresolved comments

```
scripts/list_comments.py
```

Outputs JSON: `[{id, file, line, author, body, url, outdated?}, ...]`. If empty, report "no unresolved comments" and stop.

### 2. Triage each comment

Read the referenced `file:line` (plus enough context around it). Classify each into one of:

- **fix** — the comment points to a real issue in the current code
- **skip:irrelevant** — the comment doesn't apply (wrong scope, misread, stylistic preference you disagree with)
- **skip:hallucination** — references code, APIs, or behavior that doesn't exist
- **skip:already-fixed** — addressed in a later commit on this branch

Keep a running triage table: `{id, file:line, decision, reason, short_summary}`.

### 3. Apply fixes

For every `fix` comment, edit the code. Make the minimal change that addresses the comment. If two comments suggest conflicting changes, prefer the one that keeps existing conventions and flag the conflict in the recap.

### 4. Commit fixes

Use the atomic-commit workflow (see `commit` skill / `rules/git.md`). One logical concern per commit; don't batch unrelated fixes.

### 5. Resolve threads

For each triaged comment:

```
# Fixed — resolve silently (the commit is the explanation)
scripts/resolve_comment.py --id <id>

# Skipped — resolve with a brief reply explaining why
scripts/resolve_comment.py --id <id> --reply "Not applicable: <reason>"
```

Keep replies short and specific. No filler like "Thanks for the review".

### 6. Push and recap

```
git push
```

Print a recap table to the user. One row per triaged comment; sort by status (fixed first, then skipped). Show the totals in the heading.

```
Review recap (fixed: N, skipped: M)

| Status     | File:line         | Note                                |
| ---------- | ----------------- | ----------------------------------- |
| fixed      | src/foo.py:42     | <what changed>                      |
| skipped    | src/bar.py:17    | irrelevant — <reason>               |
| skipped    | src/baz.py:88    | hallucination — <reason>            |
| skipped    | src/qux.py:12    | already-fixed in <sha>              |
```

Keep the `Note` column short (one line). Truncate long file paths from the left with `…` if needed.
