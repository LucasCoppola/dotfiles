# Terminal output, dry-run execution and the end-of-run checklist.
# All output goes to stderr.
# shellcheck shell=bash

if [ -t 2 ] && [ -z "${NO_COLOR:-}" ]; then
    DOT_C_RESET=$'\033[0m' DOT_C_BOLD=$'\033[1m' DOT_C_RED=$'\033[31m'
    DOT_C_GREEN=$'\033[32m' DOT_C_YELLOW=$'\033[33m' DOT_C_DIM=$'\033[2m'
else
    DOT_C_RESET='' DOT_C_BOLD='' DOT_C_RED='' DOT_C_GREEN='' DOT_C_YELLOW='' DOT_C_DIM=''
fi

DOT_DRY_RUN=0
DOT_TODOS=()

print_header()  { printf '\n%s== %s%s\n' "$DOT_C_BOLD" "$1" "$DOT_C_RESET" >&2; }
print_ok()      { printf '  %s✓%s %s\n' "$DOT_C_GREEN" "$DOT_C_RESET" "$1" >&2; }
print_warn()    { printf '  %s!%s %s\n' "$DOT_C_YELLOW" "$DOT_C_RESET" "$1" >&2; }
print_fail()    { printf '  %s✗%s %s\n' "$DOT_C_RED" "$DOT_C_RESET" "$1" >&2; }
print_info()    { printf '  %s-%s %s\n' "$DOT_C_DIM" "$DOT_C_RESET" "$1" >&2; }

# Show a path relative to $HOME.
display_path() {
    # shellcheck disable=SC2088 # a literal ~ for display
    case "$1" in
        "$HOME"/*) printf '~/%s' "${1#"$HOME"/}" ;;
        *) printf '%s' "$1" ;;
    esac
}

# Run a command, or only print it under --dry-run.
run_or_print() {
    if [ "$DOT_DRY_RUN" = 1 ]; then
        print_info "would run: $*"
        return 0
    fi
    "$@"
}

# Record something the user must do by hand; printed at the end of the run.
add_todo() { DOT_TODOS+=("$1"); }

print_todos() {
    [ "${#DOT_TODOS[@]}" -gt 0 ] || return 0
    print_header "Left for you"
    local todo
    for todo in "${DOT_TODOS[@]}"; do
        print_info "$todo"
    done
}

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Ask a yes/no question; defaults to no when there is no terminal.
confirm() {
    local answer
    [ -t 0 ] || return 1
    printf '  %s [y/N] ' "$1" >&2
    read -r answer || return 1
    case "$answer" in y | Y | yes) return 0 ;; *) return 1 ;; esac
}
