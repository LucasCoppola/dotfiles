# Personal Pi policies

## Repository authority

Follow applicable repository instructions and their designated coding, architecture, testing, error and design docs. Use generic skills only to fill gaps; they do not impose a global stack, architecture, naming convention or documentation requirement. Preserve repository terminology. Surface unresolved policy conflicts instead of silently migrating conventions.

## Permissions

Implement and verify the requested work, then report it. Stage, commit, push, deploy, change branches, or run an external agent CLI only when the user explicitly authorizes that operation. Invoking an implementation skill alone does not authorize its automatic commit step. Preserve unrelated working-tree changes.

## Skills and available tools

Keep manager-installed upstream skill files unmodified. Put personal/harness policy here, and repository requirements in repository docs.

Translate a skill's tool terminology into actual available capabilities:
- Load skills through `read` using their advertised paths. A separate Skill tool is optional.
- Use a real exposed sub-agent tool when available. Otherwise perform bounded sequential passes in this chat and state that fallback; do not claim separate contexts or parallel reviewers.
- Track progress in chat when no task-list tool exists. LSP and structural-search tools are optional; use shell search and file reads when available.
- For library documentation, use `find-docs` and the installed Context7 CLI. For source research, use available web tools or a temporary Git checkout. References to opensrc/grep_app/MCP methods do not mean those tools exist.

## Review scope

Resolve and state the user's actual comparison before reviewing:
- WIP/uncommitted: `git diff HEAD` for final tracked changes, plus eligible untracked files from `git ls-files --others --exclude-standard`. This includes staged and unstaged changes. Respect secret/private/generated-file exclusions.
- Staged only: `git diff --cached`.
- Before the first commit: inspect staged and unstaged diffs plus eligible untracked files; HEAD does not exist.
- Exact commit/tag or "since <revision>": compare that resolved revision directly with pinned HEAD. Use a merge-base only for a branch/PR comparison, not for every supplied revision.
- Branch plus WIP: compare the pinned branch base with the working tree and include eligible untracked files.

An empty committed diff is not an empty WIP review. Missing issue-tracker setup does not block a local review: use supplied requirements or report the unavailable Spec axis. If sub-agents are unavailable, report Standards and Spec as sequential passes. Keep review read-only unless fixes are requested.

## Design and feedback

Use Impeccable for page composition, hierarchy, flows and general UI/UX critique. Use emil-design-eng for focused motion/component interaction refinement, and break-ui for explicit data stress tests. When another skill points to an absent prototype or review-animations skill, select the relevant installed design skill instead of inventing an invocation. Project design docs and the user's brief take precedence over generic aesthetic prescriptions.

When invoking Impeccable, set `IMPECCABLE_LIVE_COPY_AGENT=chat DO_NOT_TRACK=1` for the command so its safety/telemetry defaults also apply before a new terminal inherits the shell configuration. Start live mode or hooks only when explicitly requested.

Distinguish code inspection, actual browser verification and subjective design judgment. Use synthetic data for visual experiments; respect repository privacy boundaries. A straightforward reproducible defect can use a short reproduce/fix/verify loop; use the full debugging protocol for unclear or difficult failures. Preserve explicit test-seam approval requirements.
