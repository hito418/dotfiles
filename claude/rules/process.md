# Process

## Implementation Flow

1. **Understand** — Identify existing patterns, conventions, and constraints.
2. **Test first** — Write failing tests that define the expected behavior.
3. **Implement minimal** — Just enough code to pass all tests.
4. **Refactor safely** — Clean up with passing tests as your safety net.
5. **Commit clearly** — Small, focused commits with meaningful messages.

## When Stuck (Max 3 Attempts)

- **Document failures** — Include error messages, stack traces, and what was tried.
- **Research alternatives** — Look for different approaches or solutions.
- **Reassess the problem** — Step back and verify the root cause is correctly identified.

## Quality Standards

- Pass linting, type checks, and formatting before committing.
- Pass all existing tests before committing.
- Include tests for new logic.
- Fail fast with descriptive error messages.
- Handle expected errors at the appropriate layer; avoid silent catch blocks.
