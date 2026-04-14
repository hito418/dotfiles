---
name: commit
description: Commit staged and unstaged changes as multiple atomic, conventional commits. Analyzes the working tree diff, groups related changes by logical concern, and creates one focused commit per group. Use when the user says "commit", "commit changes", "commit this", "make commits", "atomic commits", or any variation requesting to commit current work.
allowed-tools: Bash(git *), Read, Grep, Glob
---

# Atomic Commit

Commit message conventions (prefix, length, body, Co-Authored-By) live in `rules/git.md`. This skill focuses on *splitting work into atomic commits*.

## Workflow

### 1. Analyze working tree

```
git status -u
git diff
git diff --cached
```

Read changed files as needed to understand intent.

### 2. Group changes by logical concern

Partition all changes (staged + unstaged) into groups where each group is **one atomic unit of work**: a single feature, fix, refactor, or chore.

Grouping heuristics:
- Same feature/module/component → one group
- Test + implementation for the same behavior → one group
- Config/tooling changes unrelated to feature code → separate group
- Rename/move → separate group unless tightly coupled with a functional change
- Formatting-only changes → separate group (`style:`)

If everything belongs to a single concern, make one commit.

### 3. Commit each group sequentially

Order: foundational changes first, dependent changes after.

For each group, stage only the relevant files/hunks and commit:

```
git add <file ...>
git commit -m "<type>: <concise why>"
```

When a file contains changes from different groups, commit it with the group where its changes are most relevant. Note this in the body if non-obvious.

### 4. Verify

```
git log --oneline -n <number_of_commits_created>
git status
```

Confirm no changes were missed and the log reads as a clean narrative. Report the created commits to the user.
