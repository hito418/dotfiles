---
name: create-pr
description: Create a GitHub pull request from the current branch. Auto-detects the base branch from upstream tracking, analyzes commits and diffs to generate a structured PR body (linked issues, summary, test plan), pushes the branch, creates the PR via gh CLI, and assigns it to the user. Use when the user says "make a pr", "create a pr", "open a pr", "submit a pr", "send a pr", "pr this", or any variation requesting a pull request. Accepts optional issue numbers as arguments to link in the PR body.
argument-hint: "[#issue ...]"
allowed-tools: Bash(git *), Bash(gh *), Read, Grep, Glob, mcp__github__create_pull_request, mcp__github__list_pull_requests, mcp__github__pull_request_read, mcp__github__issue_read, mcp__github__list_issues, mcp__github__search_issues, mcp__github__get_file_contents, mcp__github__list_branches, mcp__github__list_commits
model: sonnet
---

# PR Creation

## Arguments

`$ARGUMENTS` — optional issue numbers (e.g., `#12`, `34`). Strip `#` prefixes for `gh` commands.

## Workflow

### 1. Gather context

Run in parallel:

```
git branch --show-current           # → $HEAD
git rev-parse --abbrev-ref HEAD@{upstream} 2>/dev/null | sed 's|origin/||'  # → $BASE (fallback: main)
gh repo view --json owner,name -q '.owner.login + "/" + .name'              # → $REPO
```

If `$HEAD` is the main/default branch, create and switch to a feature branch before proceeding.

### 2. Commit uncommitted changes

If there are staged or unstaged changes, commit them using the `commit` skill workflow (atomic, conventional commits grouped by concern) before proceeding.

### 3. Analyze changes

```
git log $BASE..$HEAD --oneline
git diff $BASE...$HEAD --stat
```

Read changed files as needed to understand the changes.

### 4. Fetch issue context

If issue numbers were provided in `$ARGUMENTS`, fetch each:

```
gh issue view <number> --json title,body,labels
```

Use issue titles and context to inform the PR summary.

### 5. Draft PR title and body

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

### 6. Push and create PR

Push the branch if it has no upstream or is ahead of remote:

```
git push -u origin $HEAD
```

Create the PR:

```
gh pr create --base $BASE --head $HEAD --title "<title>" --body "<body>" --assignee @me
```

Report the PR URL to the user.
