# The dotfiles repo itself: pull on update (keeping your uncommitted changes),
# report uncommitted changes.
# shellcheck shell=bash

component_repo_update() {
    if [ "${DOT_PULLED:-0}" = 1 ]; then
        print_ok "repo pulled"
        return 0
    fi
    if [ "$DOT_DRY_RUN" = 1 ]; then
        print_info "would run: git pull --rebase --autostash (unless incoming commits touch files you changed)"
        return 0
    fi
    git -C "$DOT_REPO" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1 || {
        print_warn "this branch has no upstream; skipped pulling"
        return 0
    }
    if ! git -C "$DOT_REPO" fetch --quiet; then
        print_warn "git fetch failed (offline?); continuing with the current checkout"
        return 0
    fi
    if [ "$(git -C "$DOT_REPO" rev-list --count 'HEAD..@{upstream}')" = 0 ]; then
        print_ok "repo is up to date"
        return 0
    fi
    # Your uncommitted changes are stashed and put back after the pull. That only
    # applies cleanly when the incoming commits leave those files alone; otherwise
    # git writes conflict markers into live configs, so don't pull at all.
    local overlap
    overlap="$(repo_files_changed_on_both_sides | tr '\n' ' ')"
    if [ -n "$overlap" ]; then
        print_warn "not pulling: changed here and upstream: $overlap"
        add_todo "commit or discard your changes to $overlap, then run \`dot update\`"
        return 0
    fi
    local before after
    before="$(git -C "$DOT_REPO" rev-parse HEAD)"
    if ! git -C "$DOT_REPO" pull --rebase --autostash --quiet; then
        # Your local commits conflict with upstream. Aborting restores the commits
        # and the stashed changes exactly as they were.
        git -C "$DOT_REPO" rebase --abort 2>/dev/null ||
            print_warn "could not abort the rebase; run \`git -C $(display_path "$DOT_REPO") status\`"
        print_warn "not pulling: your local commits conflict with upstream; rebase them by hand"
        return 0
    fi
    after="$(git -C "$DOT_REPO" rev-parse HEAD)"
    if ! git -C "$DOT_REPO" diff --quiet "$before" "$after" -- dot; then
        # The code running now is stale: start over with the pulled version.
        print_ok "repo pulled; dot changed, restarting"
        DOT_PULLED=1 exec "$DOT_REPO/dot/bin/dot" update ${DOT_ONLY:+--only "$DOT_ONLY"}
    fi
    print_ok "repo pulled"
}

# Files that both the incoming commits and your uncommitted work (including
# untracked files, which a pull refuses to overwrite) touch.
repo_files_changed_on_both_sides() {
    LC_ALL=C comm -12 \
        <(git -C "$DOT_REPO" diff --name-only 'HEAD...@{upstream}' | LC_ALL=C sort -u) \
        <({ git -C "$DOT_REPO" diff --name-only HEAD
            git -C "$DOT_REPO" ls-files --others --exclude-standard; } | LC_ALL=C sort -u)
}

component_repo_check() {
    local changes
    changes="$(git -C "$DOT_REPO" status --porcelain | wc -l | tr -d ' ')"
    if [ "$changes" = 0 ]; then
        print_ok "no uncommitted changes"
    else
        print_warn "$changes uncommitted change(s) in $(display_path "$DOT_REPO") (things you or agents changed)"
    fi
}
