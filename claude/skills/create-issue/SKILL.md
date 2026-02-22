---
name: create-issue
description: Create a GitHub issue via gh CLI. Takes the user's description, drafts a clear title and structured body, and opens the issue assigned to the user. Use when the user says "create an issue", "open an issue", "file an issue", "make an issue", "new issue", or any variation requesting a GitHub issue.
argument-hint: "<description>"
allowed-tools: Bash(gh *), Bash(git *)
model: sonnet
---

# Issue Creation

## Arguments

`$ARGUMENTS` — free-text description of the issue. May be a bug report, feature request, task, question, etc.

## Workflow

### 1. Identify repository

```
gh repo view --json owner,name -q '.owner.login + "/" + .name'
```

### 2. Draft title and body

**Title**: concise, under 72 chars. Use imperative mood when describing work (e.g., "Add dark mode toggle"). Use descriptive mood for bugs (e.g., "Login fails when session expires").

**Body**: structure based on issue type — adapt to what fits, not a rigid template. Examples:

- **Bug**: what happens, expected behavior, reproduction context if known
- **Feature**: what and why, acceptance criteria if clear
- **Task/chore**: what needs to happen

Keep it concise. Do not pad with boilerplate sections that add no information.

### 3. Create issue

```
gh issue create --repo $REPO --title "<title>" --body "<body>" --assignee @me
```

Report the issue URL to the user.
