#!/usr/bin/env bats
# GitHub logins never fail init; they end up on the checklist.

load test-helpers

setup() {
    dot_test_setup
    mkdir -p "$HOME/.ssh" "$TEST_ROOT/bin"
    printf 'key\n' >"$HOME/.ssh/id_ed25519"
    printf 'key.pub\n' >"$HOME/.ssh/id_ed25519.pub"
    # GitHub rejects the key over SSH.
    printf '#!/bin/sh\necho "Permission denied (publickey)." >&2\nexit 255\n' >"$TEST_ROOT/bin/ssh"
    chmod +x "$TEST_ROOT/bin/ssh"
    export PATH="$TEST_ROOT/bin:$PATH"
}

teardown() { dot_test_teardown; }

@test "a refused key upload goes on the checklist" {
    # gh is logged in, but GitHub refuses the upload (like a CI token).
    printf '#!/bin/sh\ncase "$1" in auth) exit 0 ;; ssh-key) echo "HTTP 403" >&2; exit 1 ;; esac\n' >"$TEST_ROOT/bin/gh"
    chmod +x "$TEST_ROOT/bin/gh"
    run dot init --only github
    [ "$status" -eq 0 ]
    [[ "$output" == *"gh auth refresh -s admin:public_key"* ]]
}

@test "without gh logged in, the key upload goes on the checklist" {
    printf '#!/bin/sh\nexit 1\n' >"$TEST_ROOT/bin/gh"
    chmod +x "$TEST_ROOT/bin/gh"
    run dot init --only github
    [ "$status" -eq 0 ]
    [[ "$output" == *"gh auth login -s admin:public_key"* ]]
}
