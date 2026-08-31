/**
 * Git Interceptor
 *
 * Three guards for agent-driven git commands:
 *
 * 1. Editor hang prevention — Sets GIT_EDITOR, GIT_SEQUENCE_EDITOR to `true`
 *    (no-op) and GIT_MERGE_AUTOEDIT to `no` so git never spawns an interactive
 *    editor (nvim, vim, etc.) that would hang the bash process.
 *
 * 2. Hook bypass prevention — Blocks any command containing `--no-verify` so
 *    the agent cannot circumvent git hooks (pre-commit, commit-msg, etc.).
 *    The agent should fix hook failures or ask the human for help instead.
 *
 * 3. Commit confirmation — Requires immediate human confirmation before an
 *    agent command can create a commit.
 *
 * The commit detector intentionally covers normal shell command forms rather
 * than acting as a security parser. It does not attempt to detect Git aliases,
 * generated scripts, encoded commands, or adversarial shell obfuscation.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

const GIT_ENV_PREFIX =
	"export GIT_EDITOR=true GIT_SEQUENCE_EDITOR=true GIT_MERGE_AUTOEDIT=no\n";

const NO_VERIFY_RE = /--no-verify\b/;

const GIT_INVOCATION_RE =
	/(?:^|[;&|(\n])\s*(?:command[ \t]+)?(?:git|(?:\/[^\s;&|()]+)*\/git)(?=[ \t\r\n]|$)/g;

const GIT_GLOBAL_OPTIONS_WITH_VALUE = new Set([
	"-C",
	"-c",
	"--config-env",
	"--exec-path",
	"--git-dir",
	"--namespace",
	"--super-prefix",
	"--work-tree",
]);

/**
 * Detects normal-form Git commands that can create a commit.
 *
 * This is deliberately conservative and is not a shell security parser.
 */
export function requiresGitCommitConfirmation(command: string): boolean {
	const normalizedCommand = command.replace(/\\\r?\n/g, " ");
	GIT_INVOCATION_RE.lastIndex = 0;
	for (const invocation of normalizedCommand.matchAll(GIT_INVOCATION_RE)) {
		const matchedInvocation = invocation[0];
		if (!matchedInvocation) continue;

		const invocationEnd = (invocation.index ?? 0) + matchedInvocation.length;
		const commandTail =
			normalizedCommand.slice(invocationEnd).split(/[;&|\n]/, 1)[0] ?? "";
		const tokens = commandTail.match(/"[^"]*"|'[^']*'|[^\s]+/g) ?? [];
		let gitSubcommand: string | undefined;
		let argumentStart = 0;

		for (let index = 0; index < tokens.length; index += 1) {
			const rawToken = tokens[index];
			if (!rawToken) continue;
			const token = rawToken.replace(/^(["'])(.*)\1$/, "$2");
			if (GIT_GLOBAL_OPTIONS_WITH_VALUE.has(token)) {
				index += 1;
				continue;
			}
			if (token.startsWith("-C") || token.startsWith("-c")) continue;
			if (token.startsWith("-")) continue;

			gitSubcommand = token;
			argumentStart = index + 1;
			break;
		}

		if (!gitSubcommand) continue;

		const argumentsAfterSubcommand = tokens.slice(argumentStart);
		const hasNoCommit = argumentsAfterSubcommand.some(
			(argument) => argument === "--no-commit" || argument === "-n",
		);

		switch (gitSubcommand) {
			case "commit":
			case "commit-tree":
			case "am":
				return true;
			case "merge":
			case "cherry-pick":
			case "revert":
				if (!hasNoCommit) return true;
				break;
			case "rebase":
				if (argumentsAfterSubcommand.includes("--continue")) return true;
				break;
		}
	}

	return false;
}

function hasGitInvocation(command: string): boolean {
	GIT_INVOCATION_RE.lastIndex = 0;
	return GIT_INVOCATION_RE.test(command);
}

const BLOCK_REASON =
	"BLOCKED: --no-verify is not allowed. Git hooks exist for a reason. " +
	"Do not attempt to bypass them. Instead: fix the underlying issue that " +
	"is causing the hook to fail, or ask the user for help.";

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (!isToolCallEventType("bash", event)) return;

		const originalCommand = event.input.command;
		if (!hasGitInvocation(originalCommand)) return;

		if (NO_VERIFY_RE.test(originalCommand)) {
			return { block: true, reason: BLOCK_REASON };
		}

		if (requiresGitCommitConfirmation(originalCommand)) {
			if (!ctx.hasUI) {
				return {
					block: true,
					reason: "Git commit blocked: confirmation requires UI",
				};
			}

			const confirmed = await ctx.ui.confirm(
				"Confirm Git commit",
				`Allow this agent command to create a Git commit?\n\n${originalCommand}`,
			);
			if (!confirmed) {
				return { block: true, reason: "Git commit blocked by user" };
			}
		}

		event.input.command = GIT_ENV_PREFIX + originalCommand;
	});
}
