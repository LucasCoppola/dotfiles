# Dotfiles: link home/ (and home/<os>/ on that OS) into $HOME. Runs before
# anything is installed, so installers find linked directories, not new ones.
# shellcheck shell=bash

component_links_install() { link_apply "${DOT_PHASE:-init}"; }

# Update never replaces a directory that holds data or defaults (link_apply).
component_links_update() { component_links_install; }

component_links_check() { link_check; }
