#!/usr/bin/env bats
# `dot update` pulls without ever writing conflict markers into live configs.

load test-helpers

setup() {
    dot_test_setup
    export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.com GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.com
    repo_file home/a "a"
    repo_file home/b "b"
    git init -q --bare -b main "$TEST_ROOT/remote.git"
    git -C "$DOT_REPO" init -q -b main
    git -C "$DOT_REPO" add -A
    git -C "$DOT_REPO" commit -qm init
    git -C "$DOT_REPO" remote add origin "$TEST_ROOT/remote.git"
    git -C "$DOT_REPO" push -q -u origin main
    git clone -q -b main "$TEST_ROOT/remote.git" "$TEST_ROOT/other"
}

teardown() { dot_test_teardown; }

# Commit and push a change from the other machine: upstream <file> <content>
upstream() {
    printf '%s\n' "$2" >"$TEST_ROOT/other/$1"
    git -C "$TEST_ROOT/other" add -A
    git -C "$TEST_ROOT/other" commit -qm "other: $1"
    git -C "$TEST_ROOT/other" push -q
}

@test "pulls when nothing is uncommitted" {
    upstream home/a "a2"
    run dot update --only repo
    [ "$status" -eq 0 ]
    [[ "$output" == *"repo pulled"* ]]
    [ "$(cat "$DOT_REPO/home/a")" = a2 ]
}

@test "pulls around uncommitted changes and local commits in other files" {
    upstream home/a "a2"
    echo mine >"$DOT_REPO/home/b"
    echo new >"$DOT_REPO/home/c"
    git -C "$DOT_REPO" add home/c
    git -C "$DOT_REPO" commit -qm local
    run dot update --only repo
    [ "$status" -eq 0 ]
    [ "$(cat "$DOT_REPO/home/a")" = a2 ]
    [ "$(cat "$DOT_REPO/home/b")" = mine ]
    [ "$(git -C "$DOT_REPO" log -1 --format=%s)" = local ]
    [ -z "$(git -C "$DOT_REPO" stash list)" ]
}

@test "does not pull when an uncommitted file also changed upstream" {
    upstream home/a "a2"
    echo mine >"$DOT_REPO/home/a"
    before="$(git -C "$DOT_REPO" rev-parse HEAD)"
    run dot update --only repo
    [ "$status" -eq 0 ]
    [[ "$output" == *"changed here and upstream: home/a"* ]]
    [ "$(cat "$DOT_REPO/home/a")" = mine ]
    [ "$(git -C "$DOT_REPO" rev-parse HEAD)" = "$before" ]
}

@test "does not pull over an untracked file that upstream adds" {
    upstream home/c "theirs"
    echo mine >"$DOT_REPO/home/c"
    run dot update --only repo
    [[ "$output" == *"changed here and upstream: home/c"* ]]
    [ "$(cat "$DOT_REPO/home/c")" = mine ]
}

@test "a local commit that conflicts is left as it was" {
    upstream home/a "a2"
    echo mine >"$DOT_REPO/home/a"
    git -C "$DOT_REPO" commit -qam local
    echo wip >"$DOT_REPO/home/b"
    before="$(git -C "$DOT_REPO" rev-parse HEAD)"
    run dot update --only repo
    [ "$status" -eq 0 ]
    [[ "$output" == *"local commits conflict"* ]]
    [ "$(git -C "$DOT_REPO" rev-parse HEAD)" = "$before" ]
    [ "$(cat "$DOT_REPO/home/a")" = mine ]
    [ "$(cat "$DOT_REPO/home/b")" = wip ]
    [ ! -d "$DOT_REPO/.git/rebase-merge" ] && [ ! -d "$DOT_REPO/.git/rebase-apply" ]
    [ -z "$(git -C "$DOT_REPO" stash list)" ]
}
