#!/usr/bin/env bats
# Linking: what gets linked, what gets replaced, and what is protected.

load test-helpers

setup() {
    dot_test_setup
    repo_file home/.zshrc
    repo_file home/.agents/skills/a/SKILL.md
    repo_file home/.config/nvim/init.lua
    repo_file home/.local/bin/tool
    repo_file home/linux/.config/hypr/hyprland.lua
    repo_file home/macos/.config/aerospace/aerospace.toml
}

teardown() { dot_test_teardown; }

@test "fresh home: links folders whole and keeps containers real" {
    run dot init --only links
    [ "$status" -eq 0 ]
    assert_linked .zshrc home/.zshrc
    assert_linked .agents home/.agents
    assert_linked .config/nvim home/.config/nvim
    assert_linked .local/bin/tool home/.local/bin/tool
    [ -d "$HOME/.config" ] && [ ! -L "$HOME/.config" ]
    [ -d "$HOME/.local/bin" ] && [ ! -L "$HOME/.local/bin" ]
}

@test "only this OS's package is linked" {
    run dot init --only links
    assert_linked .config/hypr home/linux/.config/hypr
    [ ! -e "$HOME/.config/aerospace" ]
}

@test "the OS folders are never linked as ~/linux or ~/macos" {
    run dot init --only links
    [ "$status" -eq 0 ]
    [ ! -e "$HOME/linux" ] && [ ! -L "$HOME/linux" ]
    [ ! -e "$HOME/macos" ] && [ ! -L "$HOME/macos" ]
    run dot doctor --only links
    [ "$status" -eq 0 ]
}

@test "a folder left in place in the OS package doesn't block the rest" {
    mkdir -p "$HOME/.config/hypr"
    echo mine >"$HOME/.config/hypr/notes.txt"
    run dot init --only links
    [ "$status" -eq 0 ]
    [ -f "$HOME/.config/hypr/notes.txt" ] && [ ! -L "$HOME/.config/hypr" ]
    assert_linked .config/nvim home/.config/nvim
}

@test "a file created inside a linked folder lands in the repo" {
    dot init --only links
    mkdir -p "$HOME/.agents/skills/new"
    echo x >"$HOME/.agents/skills/new/SKILL.md"
    [ -f "$DOT_REPO/home/.agents/skills/new/SKILL.md" ]
}

@test "an existing file is replaced by the repo version" {
    echo machine >"$HOME/.zshrc"
    run dot init --only links
    [ "$status" -eq 0 ]
    assert_linked .zshrc home/.zshrc
}

@test "a folder with unknown data is never deleted and not linked into" {
    mkdir -p "$HOME/.config/nvim"
    echo mine >"$HOME/.config/nvim/notes.txt"
    run dot init --only links
    [ "$status" -eq 0 ]
    [[ "$output" == *"has files that are not in the repo"* ]]
    [ -f "$HOME/.config/nvim/notes.txt" ]
    [ ! -e "$HOME/.config/nvim/init.lua" ]
    assert_linked .zshrc home/.zshrc
}

@test "init replaces a folder identical to the machine default" {
    mkdir -p "$TEST_ROOT/defaults/hypr" "$HOME/.config/hypr"
    echo default >"$TEST_ROOT/defaults/hypr/hyprland.conf"
    cp "$TEST_ROOT/defaults/hypr/hyprland.conf" "$HOME/.config/hypr/"
    run dot init --only links
    [ "$status" -eq 0 ]
    assert_linked .config/hypr home/linux/.config/hypr
}

@test "init keeps a default folder that was changed" {
    mkdir -p "$TEST_ROOT/defaults/hypr" "$HOME/.config/hypr"
    echo default >"$TEST_ROOT/defaults/hypr/hyprland.conf"
    echo changed >"$HOME/.config/hypr/hyprland.conf"
    run dot init --only links
    [ -f "$HOME/.config/hypr/hyprland.conf" ] && [ ! -L "$HOME/.config/hypr" ]
}

@test "update never replaces a default folder" {
    mkdir -p "$TEST_ROOT/defaults/hypr" "$HOME/.config/hypr"
    echo default >"$TEST_ROOT/defaults/hypr/hyprland.conf"
    cp "$TEST_ROOT/defaults/hypr/hyprland.conf" "$HOME/.config/hypr/"
    run dot update --only links
    [ ! -L "$HOME/.config/hypr" ]
    [[ "$output" == *"run \`dot init\` to replace it"* ]]
}

@test "old absolute links are replaced with relative ones" {
    ln -s "$DOT_REPO/home/.zshrc" "$HOME/.zshrc"
    ln -s /somewhere/old/.agents "$HOME/.agents"
    run dot init --only links
    [ "$status" -eq 0 ]
    assert_linked .zshrc home/.zshrc
    assert_linked .agents home/.agents
}

@test "a folder linked file by file is folded into one link" {
    mkdir -p "$HOME/.config/nvim"
    ln -s "$DOT_REPO/home/.config/nvim/init.lua" "$HOME/.config/nvim/init.lua"
    run dot doctor --only links
    [[ "$output" == *"linked file by file"* ]]
    run dot update --only links
    assert_linked .config/nvim home/.config/nvim
}

@test "the same path in two packages is an error" {
    repo_file home/linux/.zshrc
    run dot init --only links
    [ "$status" -eq 1 ]
    [[ "$output" == *"more than one package: .zshrc"* ]]
}

@test "a container that is a symlink is an error" {
    mkdir -p "$TEST_ROOT/elsewhere"
    ln -s "$TEST_ROOT/elsewhere" "$HOME/.config"
    run dot init --only links
    [ "$status" -eq 1 ]
    [[ "$output" == *"must be a real directory"* ]]
}

@test "dry run changes nothing" {
    echo machine >"$HOME/.zshrc"
    run dot init --dry-run --only links
    [ "$status" -eq 0 ]
    [ ! -L "$HOME/.zshrc" ]
    [ ! -e "$HOME/.config" ]
}

@test "running twice changes nothing and doctor passes" {
    dot init --only links
    run dot init --only links
    [ "$status" -eq 0 ]
    [[ "$output" != *"replacing"* ]]
    run dot doctor --only links
    [ "$status" -eq 0 ]
    [[ "$output" == *"links are correct"* ]]
}
