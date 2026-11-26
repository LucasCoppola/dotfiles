# dot

Sets up, updates and checks a machine (macOS, Omarchy) from this repo. Bash 3.2
compatible, so it runs on a fresh Mac, and needs nothing but git.

```sh
dot init               # set up this machine (safe to run again)
dot update             # pull, relink, install what is missing, update extras
dot doctor             # check everything; exits 1 when something needs attention
dot init --dry-run     # print what would change
dot doctor --only mise # limit any command to some components
```

## Components

`init`, `update` and `doctor` walk the same list (`DOT_COMPONENTS` in
`lib/components.sh`). Each component is one file in `lib/components/` with up to
three functions: `component_<name>_install`, `_update` and `_check`.

| Component | Does |
| --- | --- |
| `package_manager` | Homebrew on macOS (installs it); checks for yay on Omarchy |
| `repo` | Pulls on update, keeping uncommitted changes; skips when they overlap with incoming ones |
| `links` | Links `home/` into `~`, and `home/linux/` or `home/macos/` on that OS |
| `packages` | Installs what is missing from `packages/`; reports what is untracked. Never uninstalls |
| `mise` | `mise install`; doctor runs `mise doctor` and finds commands installed twice |
| `zsh` | oh-my-zsh, its two extra plugins, zsh as login shell |
| `github` | SSH key, uploads it with `gh`, switches this repo's remote to SSH |
| `agents` | Pi extensions and skills (skill updates are left uncommitted for review) |
| `nvim` | Syncs lazy.nvim plugins on update |

A failure in `package_manager` or `links` stops the run; the rest warn and continue.

## Rules

- **One owner per tool.** mise owns languages and agent CLIs
  (`home/.config/mise/config.toml`); brew/yay own everything else. Try
  `mise use -g <tool>`, then `mise use -g github:owner/repo`; curl installers are
  a last resort and become a component.
- **Updates:** run `dot update` yourself, on both OSes. It never runs on its own,
  and `omarchy update` doesn't call it. On Linux, system package upgrades stay
  with `omarchy update` (Omarchy blocks partial upgrades); on macOS, `dot update`
  upgrades the Brewfile. mise tools update themselves daily, skipping releases
  younger than 3 days.
- **Pulling** keeps your uncommitted changes (`git pull --rebase --autostash`),
  unless the incoming commits touch a file you changed. Then it doesn't pull,
  and names the files, so git never writes conflict markers into a live config.

## Linking

Directories are linked whole, so files created inside them (new skills, app
state) land in the repo. Containers that many apps write into (`.config`,
`.local`, `.local/bin`, `.local/share`, `.local/state`) stay real directories;
their entries are linked one by one. Links are made before anything is installed,
so installers find a linked directory rather than creating a real one.

When something is already at a link's place:

| Found | `init` | `update` |
| --- | --- | --- |
| A file, or a wrong/old symlink | Replaced (the repo version is in git) | Replaced |
| A directory of links into the repo | Folded into one link | Folded |
| A directory identical to the OS default (Omarchy config, `/etc/skel`) | Replaced | Reported |
| A directory with anything else | Asks; left in place without a terminal | Reported |

## Tests

```sh
dot/tests/run-tests             # shellcheck + bats (both from mise)
dot/tests/check-package-names   # every arch.txt name still exists (needs pacman)
```

CI (`.github/workflows/dot.yml`) runs both monthly and runs a real `dot init` on a
macOS runner.
