#!/usr/bin/env bats
# Package lists: parsing, and what doctor reports as missing or untracked.

load test-helpers

setup() {
    dot_test_setup
    mkdir -p "$DOT_REPO/packages" "$TEST_ROOT/bin"
    printf '# header\n\nzsh\nghostty   # terminal\n' >"$DOT_REPO/packages/arch.txt"
    printf 'linux\n' >"$DOT_REPO/packages/arch.ignore.txt"
    printf 'git\n# comment\n' >"$TEST_ROOT/omarchy/omarchy-base.packages"
    # Fake pacman: -Qq lists everything installed, -Qqe the explicit ones.
    cat >"$TEST_ROOT/bin/pacman" <<'FAKE'
#!/bin/sh
case "$1" in
    -Qq) printf 'zsh\ngit\nlinux\nlazydocker\nlibfoo\n' ;;
    -Qqe) printf 'zsh\ngit\nlinux\nlazydocker\n' ;;
esac
FAKE
    chmod +x "$TEST_ROOT/bin/pacman"
    export PATH="$TEST_ROOT/bin:$PATH"
    # shellcheck source=../lib/dot-lib.sh
    . "$DOT_REPO/dot/lib/dot-lib.sh"
}

teardown() { dot_test_teardown; }

@test "list files drop comments and blank lines" {
    run package_list_read "$DOT_REPO/packages/arch.txt"
    [ "$output" = $'zsh\nghostty' ]
}

@test "missing: listed but not installed" {
    run package_arch_missing
    [ "$output" = ghostty ]
}

@test "untracked: explicit installs in no list, Omarchy's and ignored skipped" {
    run package_arch_untracked
    [ "$output" = lazydocker ]
}
