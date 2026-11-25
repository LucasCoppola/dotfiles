# GitHub: an SSH key that GitHub accepts, and the dotfiles remote over SSH
# (the first clone is over HTTPS, before any key exists).
# shellcheck shell=bash

DOT_SSH_KEY="$HOME/.ssh/id_ed25519"

github_accepts_ssh_key() {
    # GitHub answers a successful login with exit code 1 and this message,
    # so check the message, not the exit code.
    local reply
    reply="$(ssh -T -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new \
        git@github.com 2>&1)"
    case "$reply" in *"successfully authenticated"*) return 0 ;; esac
    return 1
}

github_use_ssh_remote() {
    local url
    url="$(git -C "$DOT_REPO" remote get-url origin 2>/dev/null)" || return 0
    case "$url" in
        https://github.com/*)
            url="${url#https://github.com/}"
            run_or_print git -C "$DOT_REPO" remote set-url origin "git@github.com:${url%.git}.git"
            print_ok "dotfiles remote switched to SSH"
            ;;
    esac
}

component_github_install() {
    if [ -f "$DOT_SSH_KEY" ]; then
        print_ok "SSH key exists at $(display_path "$DOT_SSH_KEY")"
    else
        local email
        email="$(git config --global user.email)" || email="$USER@$(hostname)"
        { run_or_print mkdir -p "$HOME/.ssh" && run_or_print chmod 700 "$HOME/.ssh"; } || return 1
        run_or_print ssh-keygen -q -t ed25519 -C "$email" -N "" -f "$DOT_SSH_KEY" || return 1
    fi

    if [ "$DOT_DRY_RUN" = 1 ]; then
        return 0
    fi
    if ! github_accepts_ssh_key; then
        if command_exists gh && gh auth status >/dev/null 2>&1; then
            gh ssh-key add "$DOT_SSH_KEY.pub" --title "$(hostname)" || return 1
        else
            add_todo "add your SSH key to GitHub: gh auth login -s admin:public_key, then dot init --only github"
            return 0
        fi
    fi
    if github_accepts_ssh_key; then
        print_ok "GitHub accepts your SSH key"
        github_use_ssh_remote
    else
        print_warn "GitHub does not accept your SSH key yet"
    fi
}

component_github_check() {
    local problems=0
    if [ -f "$DOT_SSH_KEY" ]; then
        print_ok "SSH key exists"
    else
        print_fail "no SSH key at $(display_path "$DOT_SSH_KEY")"
        problems=1
    fi
    if command_exists gh && gh auth status >/dev/null 2>&1; then
        print_ok "gh is logged in"
    else
        print_fail "gh is not logged in; run \`gh auth login\`"
        problems=1
    fi
    if github_accepts_ssh_key; then
        print_ok "GitHub accepts your SSH key"
    else
        print_fail "GitHub does not accept your SSH key"
        problems=1
    fi
    return "$problems"
}
