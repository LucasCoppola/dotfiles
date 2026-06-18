# Investigation

How to drill into a finding before proposing a fix.

This process applies to all categories. The questions shift depending on the category, but the structure is the same.

## Process

### 1. Impact assessment

Before fixing anything, understand whether it matters enough to fix.

- **How often does this code path execute?** Once a day in a cron job vs. every user request — different urgency.
- **What's the blast radius?** Does this affect one user's display, or can it corrupt shared state?
- **Is there evidence of actual damage?** Logs showing errors, customer reports, data inconsistencies already in the DB. A theoretical risk with real evidence jumps priority.
- **What's the cost of *not* fixing it?** Sometimes the answer is "nothing, for the next 2 years at our growth rate" — that's useful to know.

For data integrity findings specifically:

- Query for existing bad data — if the integrity gap exists, has anything already fallen through it?
- Estimate how much data is at risk and whether it's recoverable.

For security findings specifically:

- Check whether the pattern has a known CVE or public exploit — this changes priority drastically.

### 2. Constraint discovery

Understand what makes this harder than it looks.

- **Hidden dependencies** — other code that relies on the current (broken) behavior. A function that silently swallows errors might have callers that depend on it never throwing.
- **Ordering requirements** — for sequential calls flagged as batchable: are they truly independent? Does call B use headers/cookies set by call A? Does the business logic require them to happen in order?
- **Concurrency implications** — adding a transaction or lock: what's the contention? Could it cause deadlocks with other transaction patterns?
- **Schema migration constraints** — for DB changes: is this a table with 100M rows? Can you add an index without downtime? Does the migration need to be backwards-compatible with the current code?
- **Framework constraints** — does the framework impose limitations on how this can be fixed? (e.g., Next.js server components can't use certain patterns, Hono middleware runs in a specific order)

### 3. Failure mode analysis

What can go wrong with the fix itself?

- **What if the fix introduces a regression?** Identify what tests currently cover this path. If none — that's part of the fix.
- **Partial migration risk** — if the fix involves changing a pattern used in N places, what happens if only some are changed? Is the intermediate state safe?
- **Rollback plan** — if this ships and causes problems, can it be reverted cleanly? DB migrations that drop columns can't be reverted by just re-deploying old code.
- **Edge cases in the fix** — adding `Promise.all` to batch calls: what's the error semantics? `Promise.all` fails fast — is that what you want, or do you need `Promise.allSettled`?

### 4. Propose fix

After understanding impact, constraints, and failure modes — propose a concrete change:

- **The change itself** — specific code modifications with file locations. Not pseudocode — real changes or clear enough descriptions to implement directly.
- **Tests** — what tests should be added or modified. Tests should verify the *correct* behavior, not just that the fix "works." For data integrity fixes: test the constraint, not just the happy path.
- **Migration plan** (if applicable) — for DB changes: migration steps, whether it needs to be split across deploys, whether existing data needs backfilling.
- **Monitoring** — what to watch after deployment. For performance fixes: which metric should improve and by how much. For data integrity fixes: how to verify no new bad data enters.

## When to stop investigating

Not every finding needs the full process. Use judgment:

- **Obvious fix, low risk** — e.g., adding a missing index on a FK column with a small table. Skip to propose fix.
- **High complexity, unclear impact** — run the full process. The investigation often reveals the finding is either more or less severe than it appeared.
- **User says "just fix it"** — still do a quick constraint check (step 2), but compress the process. Note any risks you're skipping over.
