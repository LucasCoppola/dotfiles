# Package manager: Homebrew on macOS; yay on Omarchy, which ships it.
# shellcheck shell=bash

component_package_manager_install() {
    if on_os linux; then
        if ! command_exists yay; then
            print_fail "yay not found; dot expects Omarchy, which ships it"
            return 1
        fi
        print_ok "yay is installed"
        return 0
    fi

    if command_exists brew; then
        print_ok "Homebrew is installed"
        return 0
    fi
    if ! xcode-select -p >/dev/null 2>&1; then
        print_fail "the Xcode Command Line Tools are missing: run \`xcode-select --install\`, then \`dot init\` again"
        return 1
    fi
    local installer
    installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        print_fail "could not download the Homebrew installer"
        return 1
    }
    run_or_print env NONINTERACTIVE=1 /bin/bash -c "$installer" || return 1
    [ "$DOT_DRY_RUN" = 1 ] && return 0
    eval "$(/opt/homebrew/bin/brew shellenv)"
    print_ok "Homebrew installed"
}

component_package_manager_update() {
    on_os macos || return 0
    run_or_print brew update
}

component_package_manager_check() {
    if on_os linux; then
        command_exists yay && print_ok "yay is installed" && return 0
        print_fail "yay not found"
        return 1
    fi
    command_exists brew && print_ok "Homebrew is installed" && return 0
    print_fail "Homebrew not found; run \`dot init\`"
    return 1
}
