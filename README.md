# dotfiles

My setup for macOS and Omarchy, managed by [`dot`](dot/README.md).

## New machine

```sh
xcode-select --install   # macOS only: installs git
git clone https://github.com/LucasCoppola/dotfiles ~/code/dotfiles && ~/code/dotfiles/dot/bin/dot init
```

`init` asks no questions on a fresh machine and ends with a short list of what is
left for you (logins). Run it again any time; it only does what is missing.

## Day to day

| | |
| --- | --- |
| Update | `dot update` (dotfiles, skills, plugins). Linux system packages: `omarchy update` |
| Check | `dot doctor`: links, missing or untracked packages, duplicates, logins |
| Install a tool | `mise use -g <tool>` first; otherwise add it to `packages/` |

## Layout

| Path | What |
| --- | --- |
| `home/` | Mirrors `~`: `home/.config/nvim` is `~/.config/nvim`. Linked on every machine |
| `home/linux/`, `home/macos/` | Also mirror `~`, linked on that OS only: `home/linux/.config/hypr` is `~/.config/hypr` |
| `packages/` | `Brewfile` (macOS), `arch.txt` and `arch.ignore.txt` (Linux) |
| `dot/` | The tool |
