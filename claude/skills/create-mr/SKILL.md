---
name: create-mr
description: Create a GitLab merge request from the current branch. Auto-detects the target branch from upstream tracking, analyzes commits and diffs to generate a structured MR body (linked issues, summary, test plan), pushes the branch, creates the MR via glab CLI, and assigns it to the user. Use when the user says "make a mr", "create a mr", "open a mr", "submit a mr", "send a mr", "mr this", "merge request", or any variation requesting a merge request. Accepts optional issue numbers as arguments to link in the MR body.
argument-hint: "[#issue ...]"
allowed-tools: Bash(git *), Bash(glab *), Read, Grep, Glob, mcp__gitlab__create_merge_request, mcp__gitlab__get_merge_request, mcp__gitlab__get_issue, mcp__gitlab__create_issue, mcp__gitlab__get_merge_request_pipelines, mcp__gitlab__search_labels
model: sonnet
---

# MR Creation

## Arguments

`$ARGUMENTS` — optional issue numbers (e.g., `#12`, `34`). Strip `#` prefixes for `glab` commands.

## Workflow

### 1. Gather context

Run in parallel:

```
git branch --show-current           # → $HEAD
git rev-parse --abbrev-ref HEAD@{upstream} 2>/dev/null | sed 's|origin/||'  # → $TARGET (fallback: main)
glab repo view --output json | jq -r '.full_path'                          # → $PROJECT
```

If `$HEAD` is the main/default branch, create and switch to a feature branch before proceeding.

### 2. Commit uncommitted changes

If there are staged or unstaged changes, commit them using the `commit` skill workflow (atomic, conventional commits grouped by concern) before proceeding.

### 3. Analyze changes

```
git log $TARGET..$HEAD --oneline
git diff $TARGET...$HEAD --stat
```

Read changed files as needed to understand the changes.

### 4. Fetch issue context

If issue numbers were provided in `$ARGUMENTS`, fetch each:

```
glab issue view <number>
```

Use issue titles and context to inform the MR summary.

### 5. Draft MR title and body

**Title**: conventional commit style, under 72 chars (e.g., `feat: add user auth flow`).

**Body** template:

```markdown
<!-- only if issues were provided -->
## Linked issues

Closes #N
Closes #M

## Summary

- <bullet points derived from commit analysis>

## Test plan

- [ ] <concrete verification steps>
```

- Omit "Linked issues" section entirely if no issues provided.
- Derive summary from commit messages and diff analysis, not generic filler.
- Test plan should list specific, actionable checks.

### 6. Push and create MR

Push the branch if it has no upstream or is ahead of remote:

```
git push -u origin $HEAD
```

Create the MR:

```
glab mr create --target-branch $TARGET --source-branch $HEAD --title "<title>" --description "<body>" --assignee @me
```

Report the MR URL to the user.
