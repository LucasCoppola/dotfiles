# Agent extras that update outside mise: Pi extensions and skills.
# Skill updates change files in the repo; review them with git before committing.
# shellcheck shell=bash

component_agents_install() {
    if command_exists pi; then
        run_or_print pi update --extensions || print_warn "pi extensions did not install; run \`pi update --extensions\`"
    fi
    agents_login_todos
}

# Only the agents installed here and not yet signed in end up on the checklist.
agents_login_todos() {
    local missing=""
    if command_exists pi && [ ! -s "$HOME/.pi/agent/auth.json" ]; then
        missing="$missing pi (/login)"
    fi
    if command_exists claude; then
        case "$(claude auth status 2>/dev/null)" in
            *'"loggedIn": true'*) ;;
            *) missing="$missing claude (claude auth login)" ;;
        esac
    fi
    [ -z "$missing" ] || add_todo "sign in to the agents you use here:$missing"
}

component_agents_update() {
    local status=0
    if command_exists pi; then
        run_or_print pi update --extensions || { print_warn "pi update --extensions failed"; status=1; }
    fi
    if command_exists npx; then
        run_or_print env DO_NOT_TRACK=1 npx --yes skills@latest update -g || { print_warn "skills update failed"; status=1; }
        if [ "$DOT_DRY_RUN" = 0 ] && [ -n "$(git -C "$DOT_REPO" status --porcelain -- home/.agents)" ]; then
            print_info "skills changed; review with: git -C $(display_path "$DOT_REPO") diff -- home/.agents"
        fi
    fi
    return "$status"
}
