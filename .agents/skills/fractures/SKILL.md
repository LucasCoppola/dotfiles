---
name: fractures
description: Find fractures in a codebase — latent operational failures that architecture reviews miss. Use when the user wants to audit code that "works but feels fragile", check reliability, or surface silent failures.
---

# Fractures

Operational issues that architecture reviews miss: data that silently corrupts, queries that degrade under load, errors swallowed, resources leaked, framework idioms misused.

## Scope

**In scope**: data integrity, performance, error handling, resource management, stack-specific best practices, security, observability. See [TAXONOMY.md](TAXONOMY.md) for categories and detection heuristics.

**On "make illegal states unrepresentable"**: this skill flags places where invalid state can enter the system. Sometimes the strict modeling (discriminated unions, separate tables) is the right call. Sometimes the simpler approach is acceptable at the current scale. The skill surfaces the tradeoff — it doesn't always prescribe the strict path. When the simpler approach is acceptable, flag it for awareness with a note on when it would stop being acceptable.

## Process

### 1. Detect stack

Read project manifests (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, etc.), config files, and entry points to identify:

- **Language and runtime** — TypeScript/Node, Rust, Go, Python, etc.
- **Frameworks** — Next.js, Hono, Axum, FastAPI, etc.
- **Data layer** — Drizzle, Prisma, SQLAlchemy, Diesel, raw SQL, etc.
- **Key libraries** — neverthrow, zod, effect, tRPC, etc.
- **Infrastructure** — what DB engine, cache layer, message queue, external APIs

Then invoke **Librarian** for each major framework/library detected. Ask specifically:

- Known anti-patterns and common mistakes
- Performance pitfalls specific to this library
- Security pitfalls — common vulnerability patterns, auth gotchas
- Data integrity concerns (e.g., ORM-specific gotchas)
- Idioms that are commonly missed or misused

**Done when**: you can name the language/runtime, framework(s), data layer, key libraries, and infrastructure — and have Librarian results for each major dependency.

### 2. Scan

Use the Task tool with `subagent_type=explore` to walk the codebase. Scan across all seven categories from [TAXONOMY.md](TAXONOMY.md), but don't follow a rigid checklist mechanically — explore organically and note where you see risk.

What to read:

- **Code paths** — especially those involving I/O, data mutation, external calls, and user input
- **Database schemas and migrations** — missing indexes, missing foreign keys, cascade rules, nullable columns that represent distinct entity shapes
- **Error handling boundaries** — where errors cross between layers, where they're caught, where they're swallowed
- **API call sites** — sequential calls that could be batched, missing timeouts, no retry logic
- **Resource acquisition** — connection pools, file handles, event listeners, subscriptions

For each concern spotted, note:

- What category it falls under (from [TAXONOMY.md](TAXONOMY.md))
- The specific code locations involved
- Why it matters — what goes wrong and under what conditions

### 3. Present findings

Present a numbered list of findings grouped by category. For each finding:

- **Category** — which of the seven categories
- **Files** — specific locations
- **Problem** — what's wrong, described concretely (not "potential performance issue" — say "these 3 API calls on lines X, Y, Z execute sequentially but are independent; ~300ms wasted per request")
- **Risk** — when does this bite? At what scale, under what conditions?
- **Tradeoff** — if applicable, note when the simpler/current approach is acceptable and when it stops being acceptable

Order findings by severity — things that can corrupt data or cause silent failures first, performance optimizations last.

Do NOT propose solutions yet. Ask the user: "Which of these would you like to investigate?"

### 4. Investigate

Once the user picks a finding, follow the investigation process in [INVESTIGATION.md](INVESTIGATION.md). The goal is to understand the full picture before changing anything — impact, constraints, failure modes, migration safety.

After investigation, propose a concrete fix with:

- The change itself
- What tests should cover it
- What to watch for after deployment
