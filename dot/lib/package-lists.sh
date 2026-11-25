# Package lists in packages/: one name per line, `#` starts a comment.
# Linux: arch.txt (installed with yay) and arch.ignore.txt (installed on
# purpose, not tracked). macOS: Brewfile, read by `brew bundle`.
# shellcheck shell=bash

DOT_OMARCHY_PACKAGE_LISTS="${DOT_OMARCHY_PACKAGE_LISTS:-/usr/share/omarchy/install}"

# Print package names from a list file, without comments or blank lines.
package_list_read() {
    [ -f "$1" ] || return 0
    sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e 's/^[[:space:]]*//' "$1" | grep -v '^$' || true
}

# Packages Omarchy installs itself; never reported as untracked.
package_omarchy_names() {
    local file
    for file in "$DOT_OMARCHY_PACKAGE_LISTS"/*.packages; do
        [ -f "$file" ] && package_list_read "$file"
    done
}

# Listed in arch.txt but not installed.
package_arch_missing() {
    LC_ALL=C comm -23 \
        <(package_list_read "$DOT_REPO/packages/arch.txt" | LC_ALL=C sort -u) \
        <(pacman -Qq | LC_ALL=C sort -u)
}

# Explicitly installed but in no list: arch.txt, arch.ignore.txt or Omarchy's.
package_arch_untracked() {
    LC_ALL=C comm -23 \
        <(pacman -Qqe | LC_ALL=C sort -u) \
        <({
            package_list_read "$DOT_REPO/packages/arch.txt"
            package_list_read "$DOT_REPO/packages/arch.ignore.txt"
            package_omarchy_names
        } | LC_ALL=C sort -u)
}
