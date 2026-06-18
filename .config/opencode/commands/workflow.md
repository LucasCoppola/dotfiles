---
description: Enforce full workflow gates (RESEARCH, SPEC, SLICES) before implementing
---

## MANDATORY WORKFLOW — COMPLETE THESE GATES IN ORDER

STOP. Do NOT write any code yet. You must complete each gate below before proceeding to the next. Output your findings for each gate visibly so the user can verify compliance.

### GATE 1: RESEARCH

Before forming any plan, investigate the codebase and relevant libraries. Use Librarian, Context7, opensrc, grep, glob, and read tools to discover existing patterns and idioms. Prefer discovered idioms over guessed ones. NEVER invent patterns — discover them.

After researching, state what you found and which patterns/idioms apply.

### GATE 2: SPEC

If no spec exists for this task, ask the user: "spec or ad hoc?" Do NOT assume ad hoc. No code without a written target. If a spec exists, read it first. Do not proceed until the user answers.

### GATE 3: SLICES

Break the work into implementation slices. One todo per slice. Present the slices using TodoWrite and wait for confirmation before implementing.

### DURING IMPLEMENTATION

- One slice at a time. Run check/lint/test after each slice before moving on.
- **REWIND**: If the direction is wrong, revert and redo. Never polish a flawed approach. Do not layer fixes on broken foundations.
- **CODIFY**: When a convention is established or corrected, encode it in AGENTS.md or project docs so it is not re-learned next session.
- **COMMIT**: Only when the user explicitly asks.

<user-request>
$ARGUMENTS
</user-request>
