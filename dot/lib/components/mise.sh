# mise: languages and agent CLIs from home/.config/mise/config.toml.
# Tools update themselves daily (tool_update.global_auto), so update only
# installs what was added to the config.
# shellcheck shell=bash

# Commands that should have exactly one install. More than one on PATH means
# two owners, and which one runs depends on PATH order.
DOT_SINGLE_OWNER_COMMANDS="node npm pnpm bun go cargo rustc gh pi claude codex plannotator kiro-cli nvim"

component_mise_install() {
    if ! command_exists mise; then
        if on_os linux; then
            print_fail "mise not found; Omarchy ships it"
            return 1
        fi
        run_or_print brew install mise || return 1
    fi
    run_or_print mise install --yes
}

component_mise_update() { component_mise_install; }

component_mise_check() {
    local problems=0 cmd
    if ! command_exists mise; then
        print_fail "mise is not installed"
        return 1
    fi
    if mise doctor >/dev/null 2>&1; then
        print_ok "mise doctor reports no problems"
    else
        print_fail "mise doctor found problems; run \`mise doctor\`"
        problems=1
    fi
    for cmd in $DOT_SINGLE_OWNER_COMMANDS; do
        mise_check_single_owner "$cmd" || problems=1
    done
    [ "$problems" = 0 ] && print_ok "no command is installed twice"
    return "$problems"
}

# Fail when distinct installs of a command are on PATH (everything under mise
# counts once, as do symlinks to the same file).
mise_check_single_owner() {
    local cmd="$1" path real seen=""
    while IFS= read -r path; do
        real="$(cd -P "$(dirname "$path")" && pwd -P)/$(basename "$path")"
        while [ -L "$real" ]; do real="$(link_target_of "$real")" || break; done
        # Shims, wrappers and activated install dirs are all one owner: mise.
        case "$real" in */mise/shims/* | */bin/mise | */mise/installs/*) real=mise ;; esac
        case " $seen " in *" $real "*) ;; *) seen="$seen $real" ;; esac
    done < <(type -aP "$cmd" 2>/dev/null)
    # shellcheck disable=SC2086 # split the list into arguments to count them
    set -- $seen
    [ $# -le 1 ] && return 0
    print_fail "$cmd is installed $# times:$(printf ' %s' "$@")"
    return 1
}
