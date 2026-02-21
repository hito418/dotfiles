---
name: pr
description: Create a GitHub pull request interactively. Gathers context through questions, delegates draft creation to a git-workflow agent, iterates with the user, then creates the PR.
argument-hint: "[#issue ...]"
allowed-tools: AskUserQuestion, Bash(gh *), Bash(git *), Read, Grep, Glob, Task
model: opus
---

Create a GitHub pull request through an interactive flow.

## Step 1 — Resolve repository and linked issues

Detect the repository from the current git remote:

```
git remote get-url origin
```

If `$ARGUMENTS` is provided, treat each argument as an issue number (with or without `#` prefix). Store them for use in the PR body. If no arguments are provided, skip issue linking entirely — do not ask about it.

## Step 2 — Resolve branches

Get the current branch:

```
git branch --show-current
```

AskUserQuestion — "Which branch should this PR be created from?" Offer the current branch as the recommended default.

AskUserQuestion — "Which base branch to merge into?" Offer `main` as the recommended default, plus other common options like `dev`.

## Step 3 — Gather PR details

Ask these questions using AskUserQuestion. Use two rounds to keep each round focused.

**Round 1:**

1. **PR type** — feat / fix / refactor / docs / chore
2. **Summary** — "Describe what this PR does." (expect free text via Other)
3. **Motivation** — "Why is this change needed?" (expect free text via Other)
4. **Breaking changes** — yes / no

**Round 2:**

1. **Test plan** — "How should this be tested?" (expect free text via Other)
2. **Additional context** — "Anything reviewers should know?" (expect free text via Other, allow skipping)

## Step 4 — Draft via git-workflow agent

Spawn a `git-workflow` agent using the Task tool:

```
subagent_type: git-workflow
```

Pass the agent:
- Repository, source branch, and base branch
- All user answers from Step 3
- Instruct it to:
  1. Run `git log <base>..<head>` and `git diff <base>...<head> --stat` to analyze changes
  2. Read changed files if needed for context
  3. Draft a PR **title** (conventional commit style, under 70 chars) and **body** using this template:

```markdown
## Summary
<bullet points from analysis + user summary>

## Motivation
<user motivation>

## Linked issues
<if issues were provided in $ARGUMENTS, list each as "Closes #N" on its own line; otherwise omit this section entirely>

## Test plan
<user test plan>

## Additional context
<user context, if any>
```

  4. Return the draft title and body

## Step 5 — Review draft with user

Present the draft to the user as formatted text.

AskUserQuestion — "How does this look?"
- **Accept** (Recommended)
- **Edit title**
- **Edit body**
- **Start over** — go back to Step 3

If the user wants to edit, ask for the new value and update the draft. Loop until accepted.

## Step 6 — Create PR

Push the branch if it has no upstream:

```
git push -u origin <branch>
```

Create the PR:

```
gh pr create --repo <repo> --base <base> --head <branch> --title "<title>" --body "<body>"
```

Report the PR URL to the user.
