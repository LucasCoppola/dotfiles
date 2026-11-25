# Loads every dot library and component, in dependency order.
# shellcheck shell=bash

# shellcheck source=output.sh
. "$DOT_REPO/dot/lib/output.sh"
# shellcheck source=platform.sh
. "$DOT_REPO/dot/lib/platform.sh"
# shellcheck source=links.sh
. "$DOT_REPO/dot/lib/links.sh"
# shellcheck source=package-lists.sh
. "$DOT_REPO/dot/lib/package-lists.sh"
# shellcheck source=components.sh
. "$DOT_REPO/dot/lib/components.sh"
# shellcheck source=main.sh
. "$DOT_REPO/dot/lib/main.sh"

for dot_component_file in "$DOT_REPO"/dot/lib/components/*.sh; do
    # shellcheck source=/dev/null
    . "$dot_component_file"
done
unset dot_component_file
