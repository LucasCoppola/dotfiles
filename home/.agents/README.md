# Agent skills

Pi reads the skills in `~/.agents/skills/`, linked to this dotfiles tree. Upstream skills are installed with the Vercel `skills` manager; keep their contents unmodified. Repository requirements belong in each repo's own docs. Personal Pi permissions, tool mappings, design routing and review-scope overrides live in [../.pi/agent/AGENTS.md](../.pi/agent/AGENTS.md).

## Installed sources

The global [.skill-lock.json](.skill-lock.json) records sources, skill paths and available commit/folder hashes. Selected Matt skills are:

- code-review, codebase-design, diagnosing-bugs, domain-modeling
- grill-with-docs, grilling, handoff, implement
- improve-codebase-architecture, setup-matt-pocock-skills, tdd
- research, writing-for-agents

Other managed skills retain their own sources: Emil's component/UI skills, Context7's find-docs, the Pi build of Impeccable, and existing bro/tech-spec utilities. Local specialty skills and system-provided Omarchy/Superwhisper symlinks are not managed by this CLI; updates should leave them alone.

No Superpowers collection is installed. The custom frontend-workflow, global coding-standards skill, local indexing/research rewrites and retired resolving-merge-conflicts skill were removed. Use Matt's research/writing-for-agents for their corresponding tasks, and ordinary Git inspection for merge-conflict work.

## Inspect and update

```sh
# Show installed global skills and their sources.
DO_NOT_TRACK=1 npx --yes skills@latest list -g -a pi

# Refresh registered global skills from their upstream sources.
DO_NOT_TRACK=1 npx --yes skills@latest update -g
```

Updates are manual, not automatic. The manager refreshes source files without rewriting the personal Pi policy. Review the resulting dotfiles diff before accepting behavioral changes; do not edit downloaded skills to keep a local fork. If upstream fixes a workaround, remove that workaround from the personal policy.

Run `/reload` in Pi after updating. Reopen the terminal when shell environment defaults change. Impeccable's live-copy fallback defaults to `chat` and CLI telemetry is disabled by shell environment, not a patched upstream launcher. The Pi policy also requires those environment values on Impeccable invocations in already-running sessions. No live server or hooks were enabled during migration.

## Restore on another machine

The skill files and global lock are part of this dotfiles tree. After the normal dotfiles links are installed, Pi can read them without downloading them again. When `XDG_STATE_HOME` is set, connect the manager's global state path to the tracked lock, preserving any existing file first:

```sh
# Only after backing up an existing state lock; do not overwrite it blindly.
mkdir -p "$XDG_STATE_HOME/skills"
ln -s "$HOME/.agents/.skill-lock.json" "$XDG_STATE_HOME/skills/.skill-lock.json"
```

With no `XDG_STATE_HOME`, the CLI uses `~/.agents/.skill-lock.json` directly. This machine's XDG state lock is already linked. Do not create a second independent registry.

To reinstall the selected Matt skills from upstream rather than the tracked files:

```sh
DO_NOT_TRACK=1 npx --yes skills@latest add mattpocock/skills -g -a pi \
  --skill code-review codebase-design diagnosing-bugs domain-modeling \
  grill-with-docs grilling handoff implement improve-codebase-architecture \
  setup-matt-pocock-skills tdd research writing-for-agents -y
```

That command installs the current upstream versions, not necessarily the commits in an older dotfiles checkout. Reinstall Impeccable from its Pi-specific source path, rather than selecting an arbitrary harness build:

```sh
DO_NOT_TRACK=1 npx --yes skills@latest add \
  https://github.com/pbakaus/impeccable/tree/main/.pi/skills/impeccable \
  -g -a pi --skill impeccable -y
```

## Migration backup

The complete pre-refresh skill tree, former lock, previous shell/settings files and local patch were saved outside skill discovery at:

`~/.local/state/skills/backups/20261116-124823-before-upstream-refresh/`

`agent-skills.tar` is the complete pre-migration skills/evaluation snapshot. `retired/` preserves removed guides. Inspect a backup before restoring only the needed files; restoring the full old registry would also restore stale records. No credentials or session files were included in the backup.
