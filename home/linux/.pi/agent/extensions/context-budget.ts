/**
 * Context budget warning
 *
 * Shows the active context size in the footer and colors it against fixed token
 * thresholds, so you can run /compact at a natural break instead of relying on
 * automatic compaction mid-task. pi's built-in footer colors at 70%/90% of the
 * window, which is 700k/900k on a 1M model — too late to be useful.
 *
 * Notifies once each time a threshold is crossed; the notice re-arms after the
 * context drops back below it (for example after /compact or /new).
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const CONTEXT_WARN_TOKENS = 120_000;
const CONTEXT_COMPACT_TOKENS = 150_000;
const STATUS_KEY = "context-budget";

type BudgetLevel = "ok" | "warn" | "compact";

function formatTokens(tokens: number): string {
  return tokens >= 1000 ? `${Math.round(tokens / 1000)}k` : `${tokens}`;
}

function budgetLevel(tokens: number): BudgetLevel {
  if (tokens >= CONTEXT_COMPACT_TOKENS) return "compact";
  if (tokens >= CONTEXT_WARN_TOKENS) return "warn";
  return "ok";
}

export default function (pi: ExtensionAPI) {
  let notifiedLevel: BudgetLevel = "ok";

  const updateContextBudget = (ctx: ExtensionContext) => {
    if (!ctx.hasUI) return;
    const tokens = ctx.getContextUsage()?.tokens;
    if (tokens == null) {
      ctx.ui.setStatus(STATUS_KEY, undefined);
      return;
    }

    const theme = ctx.ui.theme;
    const level = budgetLevel(tokens);
    const label = `ctx ${formatTokens(tokens)}`;

    if (level === "compact") {
      ctx.ui.setStatus(STATUS_KEY, theme.fg("error", `${label} · /compact`));
    } else if (level === "warn") {
      ctx.ui.setStatus(STATUS_KEY, theme.fg("warning", label));
    } else {
      ctx.ui.setStatus(STATUS_KEY, theme.fg("dim", label));
    }

    if (level === "ok") {
      notifiedLevel = "ok";
    } else if (level === "compact" && notifiedLevel !== "compact") {
      notifiedLevel = "compact";
      ctx.ui.notify(
        `Context is ${formatTokens(tokens)} tokens. Run /compact at the next natural break (or /new for a new task).`,
        "warning",
      );
    } else if (level === "warn" && notifiedLevel === "ok") {
      notifiedLevel = "warn";
      ctx.ui.notify(`Context is ${formatTokens(tokens)} tokens. Plan a /compact soon.`, "info");
    }
  };

  pi.on("session_start", async (_event, ctx) => updateContextBudget(ctx));
  pi.on("turn_end", async (_event, ctx) => updateContextBudget(ctx));
  pi.on("agent_end", async (_event, ctx) => updateContextBudget(ctx));
  pi.on("session_compact", async (_event, ctx) => updateContextBudget(ctx));
  pi.on("session_tree", async (_event, ctx) => updateContextBudget(ctx));
  pi.on("model_select", async (_event, ctx) => updateContextBudget(ctx));
}
