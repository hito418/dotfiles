---
name: create-issue
description: Create a GitHub or GitLab issue, auto-detecting the platform from the current repo's git remote. Takes the user's description, drafts a clear title and structured body, and opens the issue assigned to the user. Use when the user says "create an issue", "open an issue", "file an issue", "make an issue", "new issue", or any variation requesting an issue.
argument-hint: "<description>"
allowed-tools: Bash(git *:*), Bash(gh *:*), Bash(glab *:*), Bash(scripts/*:*), Read, Grep, Glob
model: sonnet
---

# Issue Creation

## Arguments

`$ARGUMENTS` — free-text description of the issue. May be a bug report, feature request, task, question, etc.

## Workflow

### 1. Draft title and body

**Title**: concise, under 72 chars. Imperative mood for work (e.g., "Add dark mode toggle"); descriptive for bugs (e.g., "Login fails when session expires").

**Body**: adapt structure to the issue type — don't force a rigid template.

- **Bug**: what happens, expected behavior, reproduction context if known
- **Feature**: what and why, acceptance criteria if clear
- **Task/chore**: what needs to happen

Keep it concise. No boilerplate sections.

### 2. Create the issue

Invoke the helper. It detects GitHub vs. GitLab from the remote, calls the right CLI, and prints the URL.

```
scripts/open_issue.py --title "<title>" --body "<body>"
```

Report the printed URL to the user.
