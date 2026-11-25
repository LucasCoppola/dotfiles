# The dotfiles repo itself: pull on update, report uncommitted changes.
# shellcheck shell=bash

component_repo_update() {
    if [ "${DOT_PULLED:-0}" = 1 ]; then
        print_ok "repo pulled"
        return 0
    fi
    if [ -n "$(git -C "$DOT_REPO" status --porcelain)" ]; then
        print_warn "uncommitted changes in $(display_path "$DOT_REPO"); skipped pulling"
        return 0
    fi
    local before after
    before="$(git -C "$DOT_REPO" rev-parse HEAD)"
    if ! run_or_print git -C "$DOT_REPO" pull --ff-only --quiet; then
        print_warn "git pull failed; continuing with the current checkout"
        return 0
    fi
    after="$(git -C "$DOT_REPO" rev-parse HEAD)"
    if [ "$before" = "$after" ]; then
        print_ok "repo is up to date"
    elif ! git -C "$DOT_REPO" diff --quiet "$before" "$after" -- dot; then
        # The code running now is stale: start over with the pulled version.
        print_ok "repo pulled; dot changed, restarting"
        DOT_PULLED=1 exec "$DOT_REPO/dot/bin/dot" update ${DOT_ONLY:+--only "$DOT_ONLY"}
    else
        print_ok "repo pulled"
    fi
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
