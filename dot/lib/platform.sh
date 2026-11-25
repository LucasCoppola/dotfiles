# Which OS dot runs on. DOT_OS can be preset (tests, CI).
# shellcheck shell=bash

if [ -z "${DOT_OS:-}" ]; then
    case "$(uname -s)" in
        Darwin) DOT_OS=macos ;;
        Linux) DOT_OS=linux ;;
        *) DOT_OS=unsupported ;;
    esac
fi

on_os() { [ "$DOT_OS" = "$1" ]; }

# Tools installed by mise or brew are not on PATH in a non-interactive run
# (Omarchy's post-update hook, a fresh shell). Add their usual locations.
for dot_path_dir in "$HOME/.local/share/mise/shims" "$HOME/.local/bin" /opt/homebrew/bin; do
    case ":$PATH:" in
        *":$dot_path_dir:"*) ;;
        *) [ -d "$dot_path_dir" ] && PATH="$dot_path_dir:$PATH" ;;
    esac
done
unset dot_path_dir
export PATH
