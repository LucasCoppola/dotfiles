# zsh: login shell, oh-my-zsh and the two plugins it does not update itself.
# oh-my-zsh updates itself (`zstyle ':omz:update' mode auto` in .zshrc).
# shellcheck shell=bash

DOT_ZSH_PLUGINS="zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting"

# Same path as ZSH in home/.zshrc; not $ZSH, which belongs to the calling shell.
zsh_omz_dir() { printf '%s' "$HOME/.oh-my-zsh"; }

zsh_login_shell() {
    if on_os macos; then
        dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}'
    else
        getent passwd "$USER" | cut -d: -f7
    fi
}

component_zsh_install() {
    local omz plugin dir zsh_path status=0
    omz="$(zsh_omz_dir)"
    if [ -d "$omz" ]; then
        print_ok "oh-my-zsh is installed"
    else
        run_or_print git clone --quiet --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$omz" || return 1
    fi
    for plugin in $DOT_ZSH_PLUGINS; do
        dir="$omz/custom/plugins/${plugin#*/}"
        [ -d "$dir" ] && continue
        run_or_print git clone --quiet --depth 1 "https://github.com/$plugin.git" "$dir" || status=1
    done

    zsh_path="$(command -v zsh)" || { print_fail "zsh is not installed"; return 1; }
    case "$(zsh_login_shell)" in
        */zsh) print_ok "zsh is the login shell" ;;
        *)
            if [ -t 0 ] && run_or_print chsh -s "$zsh_path"; then
                print_ok "login shell changed to zsh (takes effect at next login)"
            else
                add_todo "make zsh your login shell: chsh -s $zsh_path"
            fi
            ;;
    esac
    return "$status"
}

component_zsh_update() {
    local plugin dir status=0
    for plugin in $DOT_ZSH_PLUGINS; do
        dir="$(zsh_omz_dir)/custom/plugins/${plugin#*/}"
        [ -d "$dir" ] || continue
        run_or_print git -C "$dir" pull --quiet --ff-only || { print_warn "could not update ${plugin#*/}"; status=1; }
    done
    [ "$status" = 0 ] && print_ok "zsh plugins updated"
    return "$status"
}

component_zsh_check() {
    local problems=0 plugin
    case "$(zsh_login_shell)" in
        */zsh) print_ok "zsh is the login shell" ;;
        *) print_fail "login shell is $(zsh_login_shell), not zsh"; problems=1 ;;
    esac
    if [ -d "$(zsh_omz_dir)" ]; then
        print_ok "oh-my-zsh is installed"
    else
        print_fail "oh-my-zsh is missing"
        problems=1
    fi
    for plugin in $DOT_ZSH_PLUGINS; do
        [ -d "$(zsh_omz_dir)/custom/plugins/${plugin#*/}" ] && continue
        print_fail "zsh plugin ${plugin#*/} is missing"
        problems=1
    done
    return "$problems"
}
