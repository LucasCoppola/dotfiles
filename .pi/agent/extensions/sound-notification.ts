/** Play a notification sound when an interactive Pi agent becomes idle. */

import { existsSync } from "node:fs";
import { homedir, platform } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const soundPath = join(
	homedir(),
	".config/opencode/sounds/dragon-studio-new-notification-3-398649.mp3",
);
const player = platform() === "darwin" ? "afplay" : "paplay";

function playNotificationSound(pi: ExtensionAPI): void {
	if (!existsSync(soundPath)) {
		return;
	}

	// Playback is fire-and-forget so Pi is immediately ready for more input.
	void pi.exec(player, [soundPath], { timeout: 10_000 }).then(
		() => undefined,
		() => undefined,
	);
}

export default function soundNotification(pi: ExtensionAPI): void {
	pi.on("agent_settled", (_event, ctx) => {
		// Print-mode/background Pi processes should not produce duplicate sounds.
		if (ctx.mode === "tui" && ctx.isIdle()) {
			playNotificationSound(pi);
		}
	});
}
