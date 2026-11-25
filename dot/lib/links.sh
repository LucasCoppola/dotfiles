# Linking: home/ and home.<os>/ mirror $HOME and are linked with GNU stow.
#
# A "unit" is what gets one symlink: a top-level entry of a package, or an
# entry inside a container directory. Containers (~/.config, ~/.local/bin, ...)
# are always real directories that many apps write into, so they are created
# before stow runs and never become symlinks themselves. Every other directory
# is linked whole, so files that apps or agents create inside it land in the repo.
# shellcheck shell=bash

DOT_CONTAINER_DIRS=".config .local .local/bin .local/share .local/state"

# Where a machine's default config comes from, as "<dir>" or "<dir>:<prefix>"
# (<dir>/x is the default for $HOME/<prefix>/x). Units identical to these
# defaults are replaced without asking during `dot init`.
DOT_DEFAULT_CONFIG_DIRS="${DOT_DEFAULT_CONFIG_DIRS:-/etc/skel /usr/share/omarchy/config:.config /usr/share/omarchy/default:.config}"

# Package directories for this OS, relative to the repo.
link_packages() {
    local pkg
    for pkg in home "home.$DOT_OS"; do
        [ -d "$DOT_REPO/$pkg" ] && printf '%s\n' "$pkg"
    done
}

is_container_dir() {
    local dir
    for dir in $DOT_CONTAINER_DIRS; do
        [ "$1" = "$dir" ] && return 0
    done
    return 1
}

# Names stow ignores by default; they never become units.
is_stow_ignored() {
    case "$1" in .git | .gitignore | .gitmodules) return 0 ;; esac
    return 1
}

# Print "<package> <relative path>" for every unit, recursing into containers.
link_units() {
    local pkg
    while read -r pkg; do
        link_units_in "$pkg" ""
    done < <(link_packages)
}

link_units_in() {
    local pkg="$1" rel="$2" entry name unit
    while IFS= read -r entry; do
        name="${entry##*/}"
        is_stow_ignored "$name" && continue
        unit="${rel:+$rel/}$name"
        if [ -d "$entry" ] && [ ! -L "$entry" ] && is_container_dir "$unit"; then
            link_units_in "$pkg" "$unit"
        else
            printf '%s %s\n' "$pkg" "$unit"
        fi
    done < <(find "$DOT_REPO/$pkg${rel:+/$rel}" -mindepth 1 -maxdepth 1 | LC_ALL=C sort)
}

# Two packages providing the same unit is a layout error: stow would refuse.
link_duplicate_units() {
    link_units | cut -d' ' -f2- | LC_ALL=C sort | uniq -d
}

# The path a symlink points to, with its parent directories resolved.
link_target_of() {
    local link="$1" target dir
    target="$(readlink "$link")"
    case "$target" in /*) ;; *) target="$(dirname "$link")/$target" ;; esac
    dir="$(cd -P "$(dirname "$target")" 2>/dev/null && pwd -P)" || return 1
    printf '%s/%s' "$dir" "${target##*/}"
}

# True when every non-directory below $1 is a symlink into the repo.
# This is a unit stow linked file by file because its directory already existed.
link_dir_holds_only_repo_links() {
    local entry target
    while IFS= read -r entry; do
        [ -L "$entry" ] || return 1
        target="$(link_target_of "$entry")" || return 1
        case "$target" in "$DOT_REPO"/*) ;; *) return 1 ;; esac
    done < <(find "$1" -mindepth 1 ! -type d)
    return 0
}

# True when $HOME/<unit> is an untouched default: every file in it is identical
# to the same file in one of DOT_DEFAULT_CONFIG_DIRS (Omarchy config, /etc/skel).
link_is_default_config() {
    local unit="$1" spec dir prefix rest
    for spec in $DOT_DEFAULT_CONFIG_DIRS; do
        dir="${spec%%:*}"
        prefix=""
        [ "$spec" != "$dir" ] && prefix="${spec#*:}"
        if [ -n "$prefix" ]; then
            case "$unit" in "$prefix"/*) rest="${unit#"$prefix"/}" ;; *) continue ;; esac
        else
            rest="$unit"
        fi
        [ -e "$dir/$rest" ] && link_dir_matches "$HOME/$unit" "$dir/$rest" && return 0
    done
    return 1
}

# True when every non-directory below $1 also exists below $2 with the same content.
link_dir_matches() {
    local actual="$1" default="$2" entry rel
    while IFS= read -r entry; do
        rel="${entry#"$actual"/}"
        if [ -L "$entry" ]; then
            [ -e "$default/$rel" ] || [ -L "$default/$rel" ] || return 1
        else
            cmp -s "$entry" "$default/$rel" || return 1
        fi
    done < <(find "$actual" -mindepth 1 ! -type d)
    return 0
}

# Classify $HOME/<unit> against the repo source:
#   linked   correct relative symlink, nothing to do
#   absent   nothing there yet
#   relink   a symlink, but wrong or absolute (old dot layout): safe to remove
#   file     a regular file: the repo version wins (it is in git)
#   unfolded a directory holding only links into the repo: safe to fold
#   default  a directory with the machine's default config
#   data     a directory with content dot does not know: needs the user
link_state() {
    local unit="$1" source="$2" target="$HOME/$1"
    if [ -L "$target" ]; then
        case "$(readlink "$target")" in
            /*) printf 'relink' ;;
            *) [ "$(link_target_of "$target")" = "$source" ] && printf 'linked' || printf 'relink' ;;
        esac
    elif [ ! -e "$target" ]; then
        printf 'absent'
    elif [ ! -d "$target" ]; then
        printf 'file'
    elif [ -d "$source" ] && [ ! -L "$source" ] && link_dir_holds_only_repo_links "$target"; then
        printf 'unfolded'
    elif link_is_default_config "$unit"; then
        printf 'default'
    else
        printf 'data'
    fi
}

# Make $HOME/<unit> free for stow. Mode is "init" or "update":
# update never removes a directory that holds data or defaults.
# Returns 1 when the unit is left in place (reported, and added to the checklist).
link_clear_target() {
    local mode="$1" unit="$2" state="$3" target="$HOME/$2"
    case "$state" in
        linked | absent) return 0 ;;
        relink | file)
            print_info "replacing $(display_path "$target") ($state)"
            run_or_print rm -f "$target"
            ;;
        unfolded)
            print_info "folding $(display_path "$target") into one link"
            run_or_print rm -rf "$target"
            ;;
        default)
            if [ "$mode" != init ]; then
                print_warn "$(display_path "$target") is a real directory; run \`dot init\` to replace it"
                return 1
            fi
            print_info "replacing default config $(display_path "$target")"
            run_or_print rm -rf "$target"
            ;;
        data)
            if [ "$mode" = init ] && confirm "$(display_path "$target") has files that are not in the repo. Delete it and link the repo version?"; then
                run_or_print rm -rf "$target"
            else
                print_warn "$(display_path "$target") has files that are not in the repo; left in place"
                add_todo "move what you need from $(display_path "$target") into the repo, delete it, then run \`dot init\`"
                return 1
            fi
            ;;
    esac
    return 0
}

# Clear every unit, create containers, then let stow link everything.
link_apply() {
    local mode="$1" pkg unit state dir dupes failed=0 skipped=""
    dupes="$(link_duplicate_units)"
    if [ -n "$dupes" ]; then
        print_fail "the same path is in more than one package: $dupes"
        return 1
    fi

    for dir in $DOT_CONTAINER_DIRS; do
        if [ -L "$HOME/$dir" ] || { [ -e "$HOME/$dir" ] && [ ! -d "$HOME/$dir" ]; }; then
            print_fail "$(display_path "$HOME/$dir") must be a real directory"
            return 1
        fi
        [ -d "$HOME/$dir" ] || run_or_print mkdir -p "$HOME/$dir"
    done

    while read -r pkg unit; do
        state="$(link_state "$unit" "$DOT_REPO/$pkg/$unit")"
        # A unit left in place is on the checklist; the rest still gets linked.
        link_clear_target "$mode" "$unit" "$state" || skipped="$skipped $pkg/$unit"
    done < <(link_units)

    if [ -n "$skipped" ]; then
        # stow refuses the whole run_or_print on a conflict, so ignore what was left in place.
        local ignore_args=() item
        for item in $skipped; do
            # stow matches this against the path inside the package and anchors the end.
            ignore_args+=("--ignore=^$(link_regex_escape "${item#*/}")(/.*)?")
        done
        link_run_stow "${ignore_args[@]}" || failed=1
    else
        link_run_stow || failed=1
    fi
    [ "$failed" = 0 ] && [ "$DOT_DRY_RUN" = 0 ] && print_ok "dotfiles linked"
    return "$failed"
}

link_regex_escape() { printf '%s' "$1" | sed 's/[][\.*^$+?(){}|]/\\&/g'; }

link_run_stow() {
    local pkgs=() pkg
    while read -r pkg; do pkgs+=("$pkg"); done < <(link_packages)
    run_or_print stow --dir="$DOT_REPO" --target="$HOME" --restow "$@" "${pkgs[@]}"
}

# Doctor: report every unit that is not a correct link.
link_check() {
    local pkg unit state problems=0 linked=0 dupes
    dupes="$(link_duplicate_units)"
    if [ -n "$dupes" ]; then
        print_fail "the same path is in more than one package: $dupes"
        problems=1
    fi
    while read -r pkg unit; do
        state="$(link_state "$unit" "$DOT_REPO/$pkg/$unit")"
        case "$state" in
            linked) linked=$((linked + 1)) ;;
            absent) print_fail "$(display_path "$HOME/$unit") is not linked"; problems=1 ;;
            relink) print_fail "$(display_path "$HOME/$unit") links somewhere else"; problems=1 ;;
            file) print_fail "$(display_path "$HOME/$unit") is a file, not a link"; problems=1 ;;
            unfolded) print_warn "$(display_path "$HOME/$unit") is linked file by file, so new files there stay out of the repo; run \`dot update\`" ;;
            default | data) print_fail "$(display_path "$HOME/$unit") is a real directory, not a link"; problems=1 ;;
        esac
    done < <(link_units)
    [ "$problems" = 0 ] && print_ok "$linked links are correct"
    return "$problems"
}
