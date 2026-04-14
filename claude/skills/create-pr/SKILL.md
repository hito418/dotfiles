---
name: create-pr
description: Create a pull request (GitHub) or merge request (GitLab) from the current branch, auto-detecting the platform from the git remote. Analyzes commits and diffs to generate a structured body (linked issues, summary, test plan), pushes the branch, and assigns the PR/MR to the user. Use when the user says "make a pr", "create a pr", "open a pr", "make a mr", "merge request", "pr this", or any variation requesting a pull/merge request. Accepts optional issue numbers as arguments to link in the body.
argument-hint: "[#issue ...]"
allowed-tools: Bash(git *:*), Bash(gh *:*), Bash(glab *:*), Bash(scripts/*:*), Read, Grep, Glob
model: sonnet
---

# PR / MR Creation

## Arguments

`$ARGUMENTS` — optional issue numbers (e.g., `#12`, `34`). Strip `#` prefixes when passing to CLIs.

## Workflow

### 1. Gather context

Run in parallel:

```
git branch --show-current                                                     # → $HEAD
git rev-parse --abbrev-ref HEAD@{upstream} 2>/dev/null | sed 's|origin/||'    # → $BASE (fallback: main)
```

If `$HEAD` is the main/default branch, create and switch to a feature branch before proceeding.

### 2. Commit uncommitted changes

If there are staged or unstaged changes, commit them using the `commit` skill workflow (atomic, conventional commits grouped by concern).

### 3. Analyze changes

```
git log $BASE..$HEAD --oneline
git diff $BASE...$HEAD --stat
```

Read changed files as needed to understand the changes.

### 4. Fetch issue context (if issue numbers provided)

```
gh issue view <number>    # GitHub
glab issue view <number>  # GitLab
```

Use whichever CLI matches the repo. Skip if no numbers given.

### 5. Draft title and body

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

- Omit "Linked issues" entirely if no issues provided.
- Derive summary from commit messages and diff analysis, not generic filler.
- Test plan lists specific, actionable checks.

### 6. Create the PR/MR

Invoke the helper. It detects GitHub vs. GitLab from the remote, pushes the branch, and prints the URL.

```
scripts/open_pr.py --title "<title>" --body "<body>"
```

Pass `--base <branch>` only if the auto-detected base is wrong.

Report the printed URL to the user.
