# Components: everything dot manages, run_or_print in this order by init, update and doctor.
#
# Each component is a file in components/ defining up to three functions:
#   component_<name>_install   dot init    (must be safe to run_or_print again)
#   component_<name>_update    dot update
#   component_<name>_check     dot doctor  (return 1 for a real problem)
# A missing function means the component has nothing to do in that phase.
# shellcheck shell=bash

DOT_COMPONENTS="package_manager repo links packages mise zsh github agents nvim"
# A failure here stops init and update: later components depend on it.
DOT_REQUIRED_COMPONENTS="package_manager links"
DOT_ONLY=""

component_is_required() {
    case " $DOT_REQUIRED_COMPONENTS " in *" $1 "*) return 0 ;; esac
    return 1
}

component_is_selected() {
    [ -z "$DOT_ONLY" ] && return 0
    case ",$DOT_ONLY," in *",$1,"*) return 0 ;; esac
    return 1
}

component_validate_only() {
    local name
    for name in $(printf '%s' "$DOT_ONLY" | tr ',' ' '); do
        case " $DOT_COMPONENTS " in
            *" $name "*) ;;
            *) print_fail "unknown component: $name (components: $DOT_COMPONENTS)"; return 1 ;;
        esac
    done
}

# Run one phase (install, update, check) across all selected components.
component_run_phase() {
    local phase="$1" name fn failed="" status=0
    for name in $DOT_COMPONENTS; do
        component_is_selected "$name" || continue
        fn="component_${name}_${phase}"
        declare -F "$fn" >/dev/null || continue
        print_header "$name"
        if ! "$fn"; then
            failed="$failed $name"
            status=1
            if [ "$phase" != check ] && component_is_required "$name"; then
                print_fail "$name is required; stopping"
                break
            fi
        fi
    done

    print_todos
    if [ -n "$failed" ]; then
        print_header "Problems in:$failed"
    else
        print_header "All good"
    fi
    return "$status"
}
