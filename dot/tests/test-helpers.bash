# Shared setup: a throwaway $HOME and a fixture dotfiles repo using the real dot/.
# shellcheck shell=bash

DOT_SOURCE_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

dot_test_setup() {
    TEST_ROOT="$(cd -P "$(mktemp -d)" && pwd -P)"
    export HOME="$TEST_ROOT/home"
    export DOT_REPO="$TEST_ROOT/repo"
    export DOT_OS=linux
    export DOT_DEFAULT_CONFIG_DIRS="$TEST_ROOT/defaults:.config"
    export DOT_OMARCHY_PACKAGE_LISTS="$TEST_ROOT/omarchy"
    export NO_COLOR=1
    mkdir -p "$HOME" "$DOT_REPO" "$TEST_ROOT/defaults" "$TEST_ROOT/omarchy"
    cp -R "$DOT_SOURCE_DIR" "$DOT_REPO/dot"
}

dot_test_teardown() {
    rm -rf "$TEST_ROOT"
}

# Create a file in the fixture repo: repo_file <path> [content]
repo_file() {
    mkdir -p "$(dirname "$DOT_REPO/$1")"
    printf '%s\n' "${2:-$1}" >"$DOT_REPO/$1"
}

# Run dot from the fixture repo, without a terminal (no prompts).
dot() {
    "$DOT_REPO/dot/bin/dot" "$@" </dev/null
}

# Assert $HOME/<path> is a relative symlink resolving to repo/<source>.
assert_linked() {
    local link="$HOME/$1" expected="$DOT_REPO/$2"
    [ -L "$link" ] || { echo "$link is not a symlink" >&2; return 1; }
    case "$(readlink "$link")" in /*) echo "$link is absolute" >&2; return 1 ;; esac
    [ "$(cd -P "$(dirname "$link")" && cd -P "$(dirname "$(readlink "$link")")" && pwd -P)/$(basename "$(readlink "$link")")" = "$expected" ] ||
        { echo "$link → $(readlink "$link"), expected $expected" >&2; return 1; }
}
