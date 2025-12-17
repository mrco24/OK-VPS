#!/usr/bin/env bash

# ==============================================================================
# Nuclei Compatibility Shim
# ==============================================================================
# Purpose: Map old Nuclei flags to new ones for backward compatibility
#
# Changes:
#   v2 -> v3: -update-templates changed to -ut
#   v2 -> v3: -update changed to -up
#
# Usage: Place in ${INSTALL_DIR}/shims/nuclei and ensure shims dir is
#        first in PATH before the real nuclei binary
# ==============================================================================

# Path to the real nuclei binary
NUCLEI_REAL="${INSTALL_DIR}/bin/nuclei"

# If INSTALL_DIR not set, try to find nuclei in standard locations
if [[ -z "${INSTALL_DIR}" ]]; then
    # Find real nuclei (not this shim)
    NUCLEI_REAL=$(which -a nuclei | grep -v "shims" | head -1)
fi

# Array to hold translated arguments
args=()

# Translate arguments
for arg in "$@"; do
    case "$arg" in
        # Old template update flag -> new flag
        -update-templates|--update-templates)
            args+=("-ut")
            ;;

        # Old general update flag -> new flag
        -update|--update)
            args+=("-up")
            ;;

        # Pass through all other arguments unchanged
        *)
            args+=("$arg")
            ;;
    esac
done

# Execute real nuclei with translated arguments
exec "${NUCLEI_REAL}" "${args[@]}"
