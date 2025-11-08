#!/usr/bin/env bash

# ==============================================================================
# Smoke Test Script for Bug Bounty Tools
# ==============================================================================
# Description: Verify installed tools are working correctly
# Usage: ./smoke-test.sh [--install-dir PATH]
# ==============================================================================

set -euo pipefail

# ==============================================================================
# CONFIGURATION
# ==============================================================================

DEFAULT_INSTALL_DIR="${HOME}/.local-bounty"
INSTALL_DIR="${INSTALL_DIR:-${DEFAULT_INSTALL_DIR}}"
VERBOSE=false
RESULTS_FILE=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TOTAL=0
PASSED=0
FAILED=0
SKIPPED=0

# ==============================================================================
# FUNCTIONS
# ==============================================================================

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $*"
    ((PASSED++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $*"
    ((FAILED++))
}

log_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $*"
    ((SKIPPED++))
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

# Test if a tool is available and runnable
test_tool() {
    local tool_name="$1"
    local test_flags="${2:---version}"  # Default to --version
    local timeout_sec="${3:-5}"

    ((TOTAL++))

    if ! command -v "${tool_name}" &>/dev/null; then
        log_skip "${tool_name} (not in PATH)"
        return 1
    fi

    local output
    local exit_code

    # Try to run the tool with test flags
    if output=$(timeout "${timeout_sec}" "${tool_name}" ${test_flags} 2>&1); then
        exit_code=$?
    else
        exit_code=$?
    fi

    if [[ ${exit_code} -eq 0 ]] || [[ ${exit_code} -eq 1 ]]; then
        # Exit code 0 or 1 is often acceptable (some tools exit 1 for --help)
        if [[ "${VERBOSE}" == "true" ]]; then
            log_pass "${tool_name} - ${output:0:60}..."
        else
            log_pass "${tool_name}"
        fi
        return 0
    else
        if [[ "${VERBOSE}" == "true" ]]; then
            log_fail "${tool_name} - exit code ${exit_code}"
        else
            log_fail "${tool_name}"
        fi
        return 1
    fi
}

# Test multiple flags until one works
test_tool_multiple() {
    local tool_name="$1"
    shift
    local flags=("$@")

    if ! command -v "${tool_name}" &>/dev/null; then
        ((TOTAL++))
        log_skip "${tool_name} (not in PATH)"
        return 1
    fi

    ((TOTAL++))

    for flag_set in "${flags[@]}"; do
        if timeout 5 "${tool_name}" ${flag_set} &>/dev/null; then
            log_pass "${tool_name}"
            return 0
        fi
    done

    log_fail "${tool_name}"
    return 1
}

# ==============================================================================
# TOOL TESTS
# ==============================================================================

run_all_tests() {
    log_info "Starting smoke tests..."
    echo ""

    # ==== Subdomain Enumeration ====
    echo -e "${BLUE}=== Subdomain Enumeration ===${NC}"
    test_tool "subfinder" "-version"
    test_tool "assetfinder" "-h"
    test_tool "findomain" "--version"
    test_tool "amass" "-version"
    test_tool "chaos" "-version"
    test_tool "github-subdomains" "-h"
    test_tool "crobat" "-h"
    test_tool "gotator" "-h"
    echo ""

    # ==== DNS Resolver ====
    echo -e "${BLUE}=== DNS Resolver ===${NC}"
    test_tool "dnsx" "-version"
    test_tool "massdns" "--help"
    test_tool "puredns" "version"
    test_tool "shuffledns" "-version"
    test_tool "mapcidr" "-version"
    echo ""

    # ==== HTTP Probe ====
    echo -e "${BLUE}=== HTTP Probe ===${NC}"
    test_tool "httpx" "-version"
    test_tool "httprobe" "-h"
    echo ""

    # ==== Web Crawling ====
    echo -e "${BLUE}=== Web Crawling ===${NC}"
    test_tool "katana" "-version"
    test_tool "gospider" "-h"
    test_tool "hakrawler" "-h"
    test_tool "waybackurls" "-h"
    test_tool "gau" "--version"
    test_tool "gf" "-h"
    echo ""

    # ==== Network Scanner ====
    echo -e "${BLUE}=== Network Scanner ===${NC}"
    test_tool "nmap" "--version"
    test_tool "masscan" "--version"
    test_tool "naabu" "-version"
    echo ""

    # ==== Fuzzing Tools ====
    echo -e "${BLUE}=== Fuzzing Tools ===${NC}"
    test_tool_multiple "ffuf" "-V" "--version" "-version"
    test_tool "gobuster" "version"
    test_tool "feroxbuster" "--version"
    echo ""

    # ==== Vulnerability Scanners ====
    echo -e "${BLUE}=== Vulnerability Scanners ===${NC}"
    test_tool "nuclei" "-version"
    test_tool_multiple "sqlmap" "--version" "-h"
    echo ""

    # ==== XSS Tools ====
    echo -e "${BLUE}=== XSS Tools ===${NC}"
    test_tool "dalfox" "version"
    test_tool "kxss" "-h"
    test_tool "Gxss" "-h"
    echo ""

    # ==== Parameter Discovery ====
    echo -e "${BLUE}=== Parameter Discovery ===${NC}"
    test_tool "arjun" "-h"
    test_tool "x8" "--version"
    echo ""

    # ==== Utility Tools ====
    echo -e "${BLUE}=== Utility Tools ===${NC}"
    test_tool "anew" "-h"
    test_tool "unfurl" "-h"
    test_tool "qsreplace" "-h"
    test_tool "gron" "--version"
    test_tool "jq" "--version"
    test_tool "uro" "--help"
    test_tool "notify" "-version"
    echo ""

    # ==== System Tools ====
    echo -e "${BLUE}=== System Tools ===${NC}"
    test_tool "git" "--version"
    test_tool "curl" "--version"
    test_tool "wget" "--version"
    test_tool "go" "version"
    test_tool "python3" "--version"
    test_tool "pip3" "--version"
    echo ""
}

# ==============================================================================
# REPORT
# ==============================================================================

generate_report() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}         Smoke Test Results            ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "Total Tests:  ${TOTAL}"
    echo -e "Passed:       ${GREEN}${PASSED}${NC}"
    echo -e "Failed:       ${RED}${FAILED}${NC}"
    echo -e "Skipped:      ${YELLOW}${SKIPPED}${NC}"
    echo ""

    local success_rate=0
    if [[ ${TOTAL} -gt 0 ]]; then
        success_rate=$((PASSED * 100 / TOTAL))
    fi

    echo "Success Rate: ${success_rate}%"
    echo ""

    if [[ ${FAILED} -eq 0 ]]; then
        echo -e "${GREEN}All tests passed! ✓${NC}"
        return 0
    else
        echo -e "${YELLOW}Some tests failed. Check output above.${NC}"
        return 1
    fi
}

save_results() {
    if [[ -n "${RESULTS_FILE}" ]]; then
        cat > "${RESULTS_FILE}" <<EOF
=== Smoke Test Results - $(date) ===

Total Tests:  ${TOTAL}
Passed:       ${PASSED}
Failed:       ${FAILED}
Skipped:      ${SKIPPED}
Success Rate: $((PASSED * 100 / TOTAL))%

Install Directory: ${INSTALL_DIR}
EOF
        log_info "Results saved to: ${RESULTS_FILE}"
    fi
}

# ==============================================================================
# MAIN
# ==============================================================================

usage() {
    cat <<EOF
Smoke Test Script for Bug Bounty Tools

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --install-dir PATH    Installation directory to test (default: ${DEFAULT_INSTALL_DIR})
    --verbose, -v         Show detailed output
    --output FILE         Save results to file
    --help, -h            Show this help message

EXAMPLES:
    # Run smoke tests on default installation
    $0

    # Test custom installation directory
    $0 --install-dir /opt/bounty

    # Verbose output with results file
    $0 --verbose --output test-results.txt

EOF
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --install-dir)
                INSTALL_DIR="$2"
                shift 2
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --output)
                RESULTS_FILE="$2"
                shift 2
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Expand tilde in path
    INSTALL_DIR="${INSTALL_DIR/#\~/$HOME}"

    # Update PATH to include install directory
    export PATH="${INSTALL_DIR}/bin:${INSTALL_DIR}/shims:${INSTALL_DIR}/go/bin:${PATH}"

    # Show header
    echo -e "${GREEN}Bug Bounty Tools - Smoke Test${NC}"
    echo -e "${BLUE}Testing tools in: ${INSTALL_DIR}${NC}"
    echo ""

    # Run tests
    run_all_tests

    # Generate report
    if generate_report; then
        exit_code=0
    else
        exit_code=1
    fi

    # Save results
    save_results

    exit ${exit_code}
}

main "$@"
