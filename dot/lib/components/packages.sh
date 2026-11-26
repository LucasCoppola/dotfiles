# System packages from packages/. Installs what is missing and reports what is
# installed but in no list. Never uninstalls anything. On Linux, upgrades are
# left to `omarchy update`.
# shellcheck shell=bash

component_packages_install() {
    if on_os linux; then
        local missing=() name
        while read -r name; do missing+=("$name"); done < <(package_arch_missing)
        if [ "${#missing[@]}" = 0 ]; then
            print_ok "every package in arch.txt is installed"
            return 0
        fi
        print_info "installing: ${missing[*]}"
        run_or_print yay -S --needed --noconfirm "${missing[@]}"
        return
    fi

    if run_or_print brew bundle install --file="$DOT_REPO/packages/Brewfile" --no-upgrade; then
        print_ok "every package in the Brewfile is installed"
    else
        return 1
    fi
}

component_packages_update() {
    if on_os linux; then
        component_packages_install
        return
    fi
    run_or_print brew bundle install --file="$DOT_REPO/packages/Brewfile" --upgrade
}

component_packages_check() {
    local problems=0 name missing_names="" untracked=""
    if on_os linux; then
        while read -r name; do missing_names="$missing_names $name"; done < <(package_arch_missing)
        while read -r name; do untracked="$untracked $name"; done < <(package_arch_untracked)
        [ -n "$untracked" ] && print_warn "installed but not in arch.txt or arch.ignore.txt:$untracked"
    else
        brew bundle check --file="$DOT_REPO/packages/Brewfile" >/dev/null 2>&1 || missing_names=" (see \`brew bundle check --verbose --file=$DOT_REPO/packages/Brewfile\`)"
        untracked="$(brew_untracked | tr '\n' ' ')"
        [ -n "$untracked" ] && print_warn "installed but not in the Brewfile: $untracked"
    fi
    if [ -n "$missing_names" ]; then
        print_fail "listed but not installed:$missing_names"
        problems=1
    else
        print_ok "every listed package is installed"
    fi
    return "$problems"
}

# Casks, taps and formulae installed on request that the Brewfile doesn't list.
# `brew bundle cleanup` also lists their dependencies and cache files; skip those.
brew_untracked() {
    brew bundle cleanup --file="$DOT_REPO/packages/Brewfile" 2>/dev/null |
        awk -v leaves=" $(brew leaves --installed-on-request | tr '\n' ' ') " '
            /^Would uninstall casks:/ { s = "keep"; next }
            /^Would untap:/ { s = "keep"; next }
            /^Would uninstall formulae:/ { s = "formula"; next }
            /^(Would|Run)/ { s = ""; next }
            s == "keep" || (s == "formula" && index(leaves, " " $1 " ")) { print $1 }'
}
