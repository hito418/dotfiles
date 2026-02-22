---
name: create-issue-gl
description: Create a GitLab issue via glab CLI. Takes the user's description, drafts a clear title and structured body, and opens the issue assigned to the user. Use when the user says "create a gitlab issue", "open a gitlab issue", "file a gitlab issue", "make a gitlab issue", "new gitlab issue", or any variation requesting a GitLab issue.
argument-hint: "<description>"
allowed-tools: Bash(glab *), Bash(git *)
model: sonnet
---

# GitLab Issue Creation

## Arguments

`$ARGUMENTS` — free-text description of the issue. May be a bug report, feature request, task, question, etc.

## Workflow

### 1. Identify project

```
glab repo view --output json | jq -r '.full_path'
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
glab issue create --title "<title>" --description "<body>" --assignee @me
```

Report the issue URL to the user.
