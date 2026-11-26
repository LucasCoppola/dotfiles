# Mac handoff (temporary — delete before merging into main)

Context for the agent finishing the macOS side of the `dot` rewrite. The Linux
side (Omarchy laptop) is done and running from this branch. Read `README.md` and
`dot/README.md` first; this file holds the decisions behind them.

## Ground rules

- Work on the `dot-rewrite` branch. Don't push to `main`; merge only once the Mac works.
- The repo is public, and so are CI logs: never commit or print secrets, tokens or emails.
- Never uninstall anything automatically. `dot` only installs and reports.
- No backups when replacing files; git is the backup.
- No OS settings (`defaults write` and the like) and no work profile.
- Keep changes small. Bash 3.2 (the stock macOS bash) must run `dot`: no
  `declare -A`, `mapfile`, `${var,,}`, or `&>>`.
- Lint and test after changes: `dot/tests/run-tests` (needs stow; bats and shellcheck come from mise).

## Decisions already made

- **One owner per tool.** mise owns languages and agent CLIs
  (`home/.config/mise/config.toml`, shared by both OSes). Brew owns everything
  else on the Mac. Install preference: `mise use -g <tool>`, then
  `mise use -g github:owner/repo` or `npm:`; a curl installer is a last resort and
  gets its own component.
- **The Brewfile lists only what's actually used.** Start from `brew leaves` and
  `brew list --cask`, then ask the user about anything doubtful. Don't list
  dependencies, and don't list tools mise owns (node, go, bun, pnpm, gh, claude,
  codex...). Duplicates found on the Mac: report them to the user; don't remove them.
- `brew "stow"` and `brew "mise"` are already in `packages/Brewfile`. mise on the
  Mac comes from brew.
- Expected in the Brewfile if they're used: ghostty, neovim, the Geist Mono Nerd
  font, and aerospace (`cask "nikitabobko/tap/aerospace"`, which needs
  `tap "nikitabobko/tap"`).
- **Not tracked:** browsers and Playwright (agents handle those), the music app
  (chosen per machine), and project dependencies (they go in each project's `mise.toml`).
- **Pi is Linux-only.** `.pi` lives in `home.linux/`, and mise has `os = ["linux"]`
  on pi. The user uses Claude Code on the Mac. Skills in `home/.agents` are shared.
- **kiro-cli is undecided.** On Linux, Omarchy provides it. Decide with the user
  whether the Mac needs it (it's used when short of tokens; no kiro at work).
  If it does, add it to mise, with `os = ["macos"]` if Linux keeps Omarchy's copy.
- **Lazy mise tools** (installed on first use): codex, playwright, rust.
- **Layout:** `home.macos/` currently holds only `.config/aerospace`. Add other
  Mac-only configs found in `~/.config` only if the user wants them tracked.
- **Linking:** `dot init` replaces files and old symlinks. It folds directories of
  repo links into one link, and leaves directories holding unknown data in place
  (it asks on a terminal). It never uses `stow --adopt`.
- **Updates on the Mac:** `dot update` runs `brew update`, then
  `brew bundle install --upgrade`, then mise and the extras (skills, nvim plugins,
  zsh plugins). Changes to tracked lock files are left uncommitted for review.
- **oh-my-zsh stays,** with auto-update. `dot` installs zsh-autosuggestions and
  zsh-syntax-highlighting.
- **Logins:** `init` doesn't block on them; it ends with a checklist (gh, Claude, SSH key).

## Tasks

1. Inventory: `brew leaves; brew list --cask; mise ls; ls ~/.local/bin; ls ~/.config`.
   Triage it with the user and fill in `packages/Brewfile`.
2. Run `dot init --dry-run`, read it, then run `dot init`.
3. Run `dot doctor`, fix real problems in `dot`, and list the duplicates for the user.
4. Check the Mac paths that have never run: the Homebrew install, `brew bundle`
   install and cleanup reporting, the zsh login shell, and aerospace starting
   from the linked config.
5. Delete this file, commit, and ask the user before merging into `main` and pushing.
