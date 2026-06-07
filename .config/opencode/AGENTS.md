- In all interaction and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

## Code Quality Standards

- Make minimal, surgical changes
- **Never compromise type safety**: No `any`, no non-null assertion operator (`!`), no type assertions (`as Type`)
- **Make illegal states unrepresentable**: Model domain with ADTs/discriminated unions; parse inputs at boundaries into typed structures; if state can't exist, code can't mishandle it
- **Abstractions**: Consciously constrained, pragmatically parameterised, doggedly documented

### **ENTROPY REMINDER**
This codebase will outlive you. Every shortcut you take becomes
someone else's burden. Every hack compounds into technical debt
that slows the whole team down.

You are not just writing code. You are shaping the future of this
project. The patterns you establish will be copied. The corners
you cut will be cut again.

**Fight entropy. Leave the codebase better than you found it.**

Willing to rewind: when the agent chooses the wrong design, the user prefers reverting and reimplementing correctly over
polishing a flawed approach.

## Testing

- Write tests that verify semantically correct behavior
- **Failing tests are acceptable** when they expose genuine bugs and test correct behavior

## Git, VCS, SCM,Pull Requests, Commits

- **Never** add Claude to attribution or as a contributor PRs, commits, messages, or PR descriptions
- **gh CLI available** for GitHub operations (PRs, issues, etc.)

## Workflow

- **Before implementing: reference or produce a spec.** No code without a written target. If a spec exists, read it first. If not, ask whether to spec or proceed ad hoc.
- **Before speccing: research.** Read framework source (`repos/`, `node_modules`, Librarian) before inventing patterns. Prefer discovered idioms over guessed ones.
- **Implement in slices.** One todo per slice. Run check/lint/test after each slice before presenting.
- **Never polish a flawed approach.** If the direction is wrong, revert and redo. Do not layer fixes on broken foundations.
- **Codify decisions.** When a convention is established or corrected, encode it in AGENTS.md or project docs so it isn't re-learned next session.
- **Commit only when explicitly asked.**

## Plans

- At the end of each plan, give me a list of unresolved questions to answer, if any. Make the questions extremely concise. Sacrifice grammar for the sake of concision.

## Specialized Subagents

### Oracle
Invoke for: code review, architecture decisions, debugging analysis, refactor planning, second opinion.

### Librarian
Invoke for: understanding 3rd party libraries/packages, exploring remote repositories, discovering open source patterns.


