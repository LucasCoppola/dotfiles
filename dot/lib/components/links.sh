# Dotfiles: link home/ and home.<os>/ into $HOME with stow. Runs before
# anything is installed, so installers find linked directories, not new ones.
# shellcheck shell=bash

component_links_install() {
    if ! command_exists stow; then
        if on_os linux; then
            run_or_print yay -S --needed --noconfirm stow || return 1
        else
            run_or_print brew install stow || return 1
        fi
    fi
    link_apply "${DOT_PHASE:-init}"
}

# Update never replaces a directory that holds data or defaults (link_apply).
component_links_update() { component_links_install; }

component_links_check() {
    command_exists stow || { print_fail "stow is not installed"; return 1; }
    link_check
}
