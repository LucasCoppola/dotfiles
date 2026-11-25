# Command-line entry point.
# shellcheck shell=bash

dot_usage() {
    cat >&2 <<EOF
Usage: dot <command> [options]

Commands:
  init      Set up this machine (safe to run_or_print again)
  update    Pull the repo, relink, install what is missing, update extras
  doctor    Check everything; exits 1 when something needs attention

Options:
  -n, --dry-run        Print what would change, change nothing (init, update)
  --only a,b           Run only these components
  -h, --help           Show this help

Components, in run_or_print order: $DOT_COMPONENTS
EOF
}

dot_main() {
    local command="${1:-}"
    [ $# -gt 0 ] && shift
    # DOT_DRY_RUN and DOT_ONLY are read by output.sh and components.sh.
    # shellcheck disable=SC2034
    while [ $# -gt 0 ]; do
        case "$1" in
            -n | --dry-run) DOT_DRY_RUN=1 ;;
            --only) DOT_ONLY="${2:-}"; [ $# -gt 1 ] && shift ;;
            --only=*) DOT_ONLY="${1#--only=}" ;;
            -h | --help) dot_usage; return 0 ;;
            *) print_fail "unknown option: $1"; dot_usage; return 2 ;;
        esac
        shift
    done

    if [ "$DOT_OS" = unsupported ]; then
        print_fail "dot supports macOS and Linux (Omarchy), not $(uname -s)"
        return 1
    fi
    component_validate_only || return 2

    case "$command" in
        init) DOT_PHASE=init component_run_phase install ;;
        update) DOT_PHASE=update component_run_phase update ;;
        doctor) DOT_DRY_RUN=0 component_run_phase check ;;
        -h | --help | help | "") dot_usage; [ -n "$command" ] ;;
        *) print_fail "unknown command: $command"; dot_usage; return 2 ;;
    esac
}
