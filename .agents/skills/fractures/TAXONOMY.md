# Taxonomy

Seven categories of operational concern. Each includes detection heuristics — structural patterns to look for regardless of framework. Framework-specific instances are discovered via Librarian during the detect step.

## 1. Data integrity

Places where invalid, orphaned, or inconsistent state can enter and persist in the system.

### Detection heuristics

- **Missing constraints at the DB level** — nullable columns that should be NOT NULL, missing foreign keys, missing unique constraints, missing CHECK constraints. The DB should enforce invariants, not just the application.
- **Orphanable records** — DELETE without CASCADE or application-level cleanup. What happens to child records when a parent is deleted?
- **Missing transactions around multi-step writes** — two or more writes that must succeed together but aren't wrapped in a transaction. Partial failure leaves inconsistent state.
- **Race conditions on read-modify-write** — reading a value, computing something, writing it back without locking or optimistic concurrency. Two concurrent requests can clobber each other.
- **Impossible states representable** — nullable fields that encode distinct entity shapes (e.g., `type: "admin"` with `adminLevel: number | null` and `customerPlan: string | null`), enum/string unions where invalid values aren't rejected at parse boundaries. See Scope in SKILL.md for tradeoff guidance.
- **Implicit ordering dependencies** — code that assumes rows come back in insertion order, or that two async operations complete in a specific order, without enforcing it.
- **Deadlock potential** — multiple locks or transactions acquired in inconsistent order across code paths.
- **Shared mutable state without synchronization** — in-memory caches, global singletons, or module-level variables mutated from concurrent requests without locking.
- **Fire-and-forget background work** — async work kicked off without awaiting or monitoring, where silent failure leaves state half-updated.
- **Non-idempotent queue/worker handlers** — retried messages that create duplicates or apply side effects twice.
- **Inconsistent response shapes at API boundaries** — sometimes `{data}`, sometimes raw, sometimes `{error}`. Consumers can't reliably parse responses.
- **Unparsed external input crossing boundaries** — user or API input accepted and routed deeper into the system without parsing/validation at the edge. Parse, don't validate — transform into typed structures at the boundary.
- **Schema/migration gaps** — migrations that add columns without defaults to non-empty tables, migrations that drop constraints without verifying data, missing indexes on foreign keys.

### Questions to ask

- If this write fails halfway through, what state is the system in?
- Can two concurrent requests create contradictory data?
- Can two concurrent operations deadlock?
- If I delete this record, what breaks?
- Can this column/field hold a value that makes no business sense?

## 2. Performance

Code that works correctly but degrades under load, at scale, or with larger datasets.

### Detection heuristics

- **N+1 queries** — a query inside a loop, or an ORM lazy-loading related records one at a time. Look for any data fetch inside `.map()`, `.forEach()`, `for...of`, or equivalent.
- **Sequential-but-independent calls** — multiple `await` statements in sequence where the calls don't depend on each other's results. Could be `Promise.all` / `join!` / equivalent.
- **Missing database indexes** — columns used in WHERE, JOIN, ORDER BY, or GROUP BY without an index. Especially foreign key columns.
- **Unbounded queries** — `SELECT *` or `findMany()` without LIMIT/pagination. Works fine with 100 rows, falls over with 100k.
- **Unnecessary data fetching** — selecting all columns when only a few are needed, loading full objects when only an ID is required, fetching data that's already available in scope.
- **Repeated computation** — the same expensive calculation or data fetch happening multiple times in a request lifecycle. Missing memoization, caching, or hoisting.
- **Large payloads** — API responses that return entire objects when the consumer only needs a subset. Over-fetching from APIs you call, over-sending in APIs you serve.
- **Missing pagination/streaming for large datasets** — loading entire datasets into memory instead of streaming or paginating.
- **Synchronous blocking in async contexts** — CPU-heavy work on the event loop (Node.js), blocking the runtime thread (Tokio), holding a connection while doing CPU work.

### Questions to ask

- What happens when this table has 1M rows instead of 1k?
- How many network round-trips does this code path make?
- If 100 users hit this endpoint simultaneously, what breaks first?
- Is this data fetched more than once per request?

## 3. Error handling

Places where errors are lost, mishandled, or create partial failures without recovery.

### Detection heuristics

- **Swallowed errors** — empty `catch` blocks, `.catch(() => {})`, `_ = result` in Rust, errors logged but not propagated or handled.
- **Missing timeouts** — HTTP calls, database queries, or external API requests without timeout configuration. Can hang indefinitely under network issues.
- **No retry logic on transient failures** — calls to external services that fail on network blips without retry. Especially relevant for idempotent operations.
- **Partial failure without rollback** — multi-step operations where step 3 fails but steps 1 and 2 already committed side effects. Related to data integrity, but the issue here is error *recovery*, not constraint enforcement.
- **Error type information lost** — catching a typed error and re-throwing a generic one (`throw new Error("something went wrong")`), or collapsing a `Result` type into a boolean.
- **Inconsistent error handling patterns** — some modules use Result types (neverthrow/effect), others throw, others return null. Mixed patterns at module boundaries create gaps.
- **Missing error boundaries** — in UI: a failing component crashes the entire page. In APIs: an error in one part of a batch response fails the entire request.
- **Catch-all at the wrong level** — a top-level try/catch that silently handles errors that should have been handled closer to the source with specific recovery logic.

### Questions to ask

- If this external call fails, does the user see a helpful error or a white screen?
- If this throws, what state has already been modified?
- Can this operation hang forever?
- Is the error information preserved well enough to debug in production?

## 4. Resource management

Resources that are acquired but not guaranteed to be released, or that accumulate over time.

### Detection heuristics

- **Unclosed database connections** — connections opened manually without `using`, `try/finally`, context managers, or RAII. Connection pool exhaustion under load.
- **Event listener / subscription leaks** — `addEventListener`, `subscribe()`, `on()` without corresponding cleanup. Especially in component lifecycles (React `useEffect` without cleanup).
- **File handle leaks** — files opened for reading/writing without guaranteed close on all code paths (including error paths).
- **Timer leaks** — `setInterval` / `setTimeout` without cleanup. Recurring timers that outlive their intended scope.
- **Unbounded in-memory accumulation** — caches without eviction, arrays that grow per-request without bounds, Maps used as caches without size limits.
- **Connection pool misconfiguration** — pool size too small for concurrency, no idle timeout, no connection health checks.
- **Missing cleanup in lifecycle hooks** — framework-specific: React effects without cleanup returns, Rust `Drop` not implemented, Go deferred closes missing.

### Questions to ask

- If this code runs 10,000 times, does memory stay flat?
- On the error path, is this resource still released?
- Does this subscription/listener outlive the thing that created it?
- What happens to the connection pool under sustained high concurrency?

## 5. Stack practices

Framework and library usage that works but ignores known best practices, uses deprecated patterns, or misses idioms that exist for good reasons.

### Detection heuristics

This category is inherently framework-specific. The detect step uses Librarian to discover anti-patterns for the project's actual stack. Common cross-framework patterns:

- **Deprecated API usage** — using APIs that have been superseded by better alternatives in the current version of the library.
- **Fighting the framework** — working around framework conventions instead of using them. Usually a sign the framework offers a built-in solution.
- **Missing framework-provided safety features** — e.g., not using parameterized queries (SQL injection), not using CSRF tokens, not using built-in input sanitization.
- **Incorrect async patterns** — fire-and-forget promises without error handling, blocking async runtimes, mixing sync and async I/O.
- **ORM misuse** — using the ORM in ways that generate inefficient SQL, bypassing the ORM's type safety, or not using features that prevent common mistakes (e.g., Drizzle's relational queries vs. manual joins).
- **Type system underuse** — using `string` where a union type exists, using `any`/`unknown` at boundaries instead of parsing with zod/valibot, not leveraging discriminated unions for state machines.
- **Configuration drift** — config that was correct for an earlier version of the framework but is now suboptimal or ignored.

### Questions to ask

- Does this framework have a built-in way to do this?
- Is this the current recommended pattern, or a legacy one?
- What does the framework's type system offer that this code isn't using?
- Would a framework expert look at this and wince?

## 6. Security

Places where the system is exposed to unauthorized access, data leakage, or exploitation.

### Detection heuristics

- **Missing auth/authz checks** — endpoints or operations that don't verify identity or permissions. Routes that assume the caller is authorized because they're "internal."
- **Secrets in source** — hardcoded API keys, tokens, credentials, or connection strings. Secrets that end up in logs or error messages.
- **Injection surfaces** — SQL built with string concatenation, shell commands with unsanitized input, user-controlled paths used in file operations, SSRF via user-supplied URLs.
- **Timing-unsafe comparisons** — comparing secrets, tokens, or hashes with `===` or `==` instead of constant-time comparison. Enables timing attacks.
- **Permissive CORS / missing rate limiting** — `Access-Control-Allow-Origin: *` on authenticated endpoints, no throttling on auth or sensitive endpoints.
- **Exposed debug/admin surface in production** — debug routes, stack traces in error responses, admin panels without auth, verbose logging of sensitive data.
- **Insecure deserialization** — parsing untrusted input with `eval`, `pickle.loads`, `JSON.parse` into executable contexts, or deserializing into types without validation.

### Questions to ask

- If an unauthenticated user hits this endpoint, what happens?
- Is this secret in version control or in logs?
- Can user input reach a shell, query, or file path unescaped?
- What's the worst thing an authenticated but unprivileged user can do?

## 7. Observability

Places where failures, performance issues, or misbehavior would go unnoticed in production.

### Detection heuristics

- **Critical paths with no logging** — error handlers that swallow silently, catch blocks that recover but don't record, business-critical operations with no audit trail.
- **Logs without actionable context** — `log("error occurred")` with no request ID, user ID, or relevant state. Useless for debugging.
- **No request/correlation IDs** — requests that cross async boundaries or services with no way to trace them end-to-end.
- **Missing health checks** — no readiness/liveness probes, or probes that return 200 without actually checking dependencies (DB, cache, external APIs).
- **Silent degradation** — failures that fall back to defaults without alerting. The system "works" but is serving stale data or skipping steps, and nobody knows.

### Questions to ask

- If this fails at 3am, can you tell what happened from logs alone?
- Can you trace a single request across all the services it touches?
- If a dependency goes down, how long before someone notices?
- Is the system distinguishable from "working correctly" when it's silently degraded?
