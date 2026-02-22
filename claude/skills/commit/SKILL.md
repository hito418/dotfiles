---
name: commit
description: Commit staged and unstaged changes as multiple atomic, conventional commits. Analyzes the working tree diff, groups related changes by logical concern, and creates one focused commit per group. Use when the user says "commit", "commit changes", "commit this", "make commits", "atomic commits", or any variation requesting to commit current work.
allowed-tools: Bash(git *), Read, Grep, Glob
---

# Atomic Commit

## Workflow

### 1. Analyze working tree

```
git status -u
git diff
git diff --cached
```

Read changed files as needed to understand intent.

### 2. Group changes by logical concern

Partition all changes (staged + unstaged) into groups where each group represents **one atomic unit of work**: a single feature, fix, refactor, or chore.

Grouping heuristics:
- Same feature/module/component → one group
- Test + implementation for the same behavior → one group
- Config/tooling changes unrelated to feature code → separate group
- Rename/move → separate group unless tightly coupled with a functional change
- Formatting-only changes → separate group (`style:`)

If everything belongs to a single concern, make one commit.

### 3. Commit each group sequentially

For each group, stage only the relevant files/hunks and commit:

```
git add <file ...>
git commit -m "<type>: <concise why>"
```

When a file contains changes belonging to different groups, commit it with the group where it has the most relevant changes. Note this in the commit message body if needed.

Commit message rules:
- Conventional commit prefix: `feat:`, `fix:`, `refactor:`, `style:`, `test:`, `docs:`, `chore:`, `build:`, `ci:`
- Subject line ≤ 72 chars
- Explain *why*, not *what*
- No `Co-Authored-By` line
- Add a body (blank line after subject) only if the *why* isn't obvious from the subject

Order commits logically: foundational changes first, dependent changes after.

### 4. Verify

```
git log --oneline -n <number_of_commits_created>
git status
```

Confirm no changes were missed and the log reads as a clean narrative.

Report the created commits to the user.
