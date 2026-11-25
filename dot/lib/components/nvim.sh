# Neovim plugins (lazy.nvim). Only updated; the config itself is linked.
# shellcheck shell=bash

component_nvim_update() {
    command_exists nvim || return 0
    run_or_print nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 && print_ok "neovim plugins synced" && return 0
    print_warn "neovim plugin sync failed; open nvim and run :Lazy"
    return 1
}
