#!/usr/bin/env bash

# ==============================================================================
# ffuf Compatibility Shim
# ==============================================================================
# Purpose: Map old ffuf flags to new ones for backward compatibility
#
# Changes:
#   v1.x: used -w for wordlist
#   v2.x: changed to --wordlist (though -w still works as alias)
#
# This is a minimal example showing flag translation
# ==============================================================================

FFUF_REAL="${INSTALL_DIR}/bin/ffuf"

if [[ -z "${INSTALL_DIR}" ]]; then
    FFUF_REAL=$(which -a ffuf | grep -v "shims" | head -1)
fi

args=()

# In practice, ffuf maintains good backward compatibility
# This shim is more of a demonstration of the pattern

for arg in "$@"; do
    case "$arg" in
        # Example: if old version used different flag name
        # --old-flag)
        #     args+=("--new-flag")
        #     ;;

        # Pass through all arguments
        *)
            args+=("$arg")
            ;;
    esac
done

exec "${FFUF_REAL}" "${args[@]}"
