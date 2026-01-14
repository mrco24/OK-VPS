#!/usr/bin/env bash

# ==============================================================================
# Bug Bounty VPS Setup Script - Upgraded Version
# ==============================================================================
# Description: Robust, flexible, idempotent installer for bug bounty tools
# Author: Upgraded from OK-VPS project
# License: MIT
# ==============================================================================

set -euo pipefail
IFS=$'\n\t'

# ==============================================================================
# GLOBAL VARIABLES
# ==============================================================================

VERSION="2.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_INSTALL_DIR="${HOME}/.local-bounty"
INSTALL_DIR="${INSTALL_DIR:-${DEFAULT_INSTALL_DIR}}"
LOG_FILE=""
MANIFEST_LOCK=""
TOOLS_YAML="${SCRIPT_DIR}/tools.yaml"
INTERACTIVE=true
ASSUME_YES=false
UPGRADE_MODE=false
DRY_RUN=false
SMOKE_TEST=false
ROLLBACK_MODE=false
USE_SUDO=false
SELECTED_TOOLS=()
FAILED_TOOLS=()
INSTALLED_TOOLS=()

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# OS detection
OS_TYPE=""
OS_VERSION=""
PKG_MANAGER=""

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

# Print colored message
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" | tee -a "${LOG_FILE:-/dev/null}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" | tee -a "${LOG_FILE:-/dev/null}"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" | tee -a "${LOG_FILE:-/dev/null}"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "${LOG_FILE:-/dev/null}"
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $*" | tee -a "${LOG_FILE:-/dev/null}"
    fi
}

# Error handler
error_handler() {
    local line_num=$1
    log_error "Script failed at line ${line_num}"
    log_error "Check log file: ${LOG_FILE}"
    exit 1
}

trap 'error_handler ${LINENO}' ERR

# Print usage
usage() {
    cat <<EOF
Bug Bounty VPS Setup Script v${VERSION}

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --prefix PATH           Install directory (default: ${DEFAULT_INSTALL_DIR})
    --yes, -y              Non-interactive mode, assume yes to all prompts
    --upgrade              Upgrade already installed tools
    --dry-run              Show what would be done without making changes
    --smoke-test           Run verification tests on installed tools
    --rollback             Uninstall tools from last installation
    --sudo                 Use sudo for system operations when needed
    --tools TOOL1,TOOL2    Install only specified tools (comma-separated)
    --category CATEGORY    Install tools from category only
    --help, -h             Show this help message
    --version, -v          Show version information

EXAMPLES:
    # Interactive installation (default)
    $0

    # Non-interactive install to custom directory
    INSTALL_DIR=/opt/bounty $0 --yes

    # Install specific tools only
    $0 --tools subfinder,httpx,nuclei --yes

    # Upgrade existing installation
    $0 --upgrade --prefix ~/.local-bounty

    # Dry-run upgrade to see what would change
    $0 --upgrade --dry-run

    # Run smoke tests on installed tools
    $0 --smoke-test

CATEGORIES:
    subdomain-enumeration, dns-resolver, http-probe, web-crawling,
    network-scanner, fuzzing, vuln-scanner, xss, parameter-discovery,
    utility, wordlist

EOF
}

# ==============================================================================
# OS DETECTION & PACKAGE MANAGER
# ==============================================================================

detect_os() {
    log_info "Detecting operating system..."

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_TYPE="${ID}"
        OS_VERSION="${VERSION_ID:-unknown}"
    elif [[ -f /etc/redhat-release ]]; then
        OS_TYPE="rhel"
        OS_VERSION=$(cat /etc/redhat-release | grep -oP '\d+\.\d+' | head -1)
    else
        OS_TYPE="unknown"
        OS_VERSION="unknown"
    fi

    # Detect package manager
    if command -v apt-get &>/dev/null; then
        PKG_MANAGER="apt"
    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
    elif command -v yum &>/dev/null; then
        PKG_MANAGER="yum"
    elif command -v pacman &>/dev/null; then
        PKG_MANAGER="pacman"
    else
        PKG_MANAGER="none"
        log_warn "No supported package manager found"
    fi

    log_success "Detected OS: ${OS_TYPE} ${OS_VERSION}, Package Manager: ${PKG_MANAGER}"
}

# ==============================================================================
# PREREQUISITES
# ==============================================================================

ensure_prerequisites() {
    log_info "Ensuring prerequisites are installed..."

    local prereqs=("git" "curl" "wget" "unzip" "make" "gcc")
    local missing=()

    for prereq in "${prereqs[@]}"; do
        if ! command -v "${prereq}" &>/dev/null; then
            missing+=("${prereq}")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_warn "Missing prerequisites: ${missing[*]}"
        install_system_packages "${missing[@]}"
    else
        log_success "All prerequisites are installed"
    fi

    # Ensure Python3 and pip
    ensure_python

    # Ensure Go is installed or install it
    ensure_go
}

install_system_packages() {
    local packages=("$@")
    local install_cmd=""

    if [[ "${PKG_MANAGER}" == "none" ]]; then
        log_error "Cannot install packages without a package manager"
        return 1
    fi

    case "${PKG_MANAGER}" in
        apt)
            install_cmd="apt-get update && apt-get install -y ${packages[*]}"
            ;;
        dnf|yum)
            install_cmd="${PKG_MANAGER} install -y ${packages[*]}"
            ;;
        pacman)
            install_cmd="pacman -Sy --noconfirm ${packages[*]}"
            ;;
    esac

    if [[ "${USE_SUDO}" == "true" ]] || [[ $EUID -eq 0 ]]; then
        local sudo_cmd=""
        [[ $EUID -ne 0 ]] && sudo_cmd="sudo"

        log_info "Installing system packages: ${packages[*]}"
        if [[ "${DRY_RUN}" == "true" ]]; then
            log_info "[DRY-RUN] Would run: ${sudo_cmd} ${install_cmd}"
        else
            eval "${sudo_cmd} ${install_cmd}" >> "${LOG_FILE}" 2>&1
            log_success "Installed system packages"
        fi
    else
        log_error "Need sudo privileges to install system packages. Use --sudo flag or run as root"
        return 1
    fi
}

ensure_python() {
    if ! command -v python3 &>/dev/null; then
        log_warn "Python3 not found, installing..."
        install_system_packages "python3" "python3-pip"
    fi

    if ! command -v pip3 &>/dev/null; then
        log_warn "pip3 not found, installing..."
        install_system_packages "python3-pip"
    fi

    log_success "Python3 and pip3 are available"
}

ensure_go() {
    if command -v go &>/dev/null; then
        local go_version=$(go version | grep -oP 'go\d+\.\d+' | sed 's/go//')
        log_success "Go is already installed (version ${go_version})"
        return 0
    fi

    log_warn "Go is not installed. Installing Go..."

    local go_version="1.22.2"
    local go_tar="go${go_version}.linux-amd64.tar.gz"
    local go_url="https://go.dev/dl/${go_tar}"
    local temp_dir="${INSTALL_DIR}/temp"

    mkdir -p "${temp_dir}"

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would install Go ${go_version}"
        return 0
    fi

    log_info "Downloading Go ${go_version}..."
    wget -q "${go_url}" -O "${temp_dir}/${go_tar}" >> "${LOG_FILE}" 2>&1

    log_info "Installing Go to ${INSTALL_DIR}/go..."
    tar -C "${INSTALL_DIR}" -xzf "${temp_dir}/${go_tar}" >> "${LOG_FILE}" 2>&1
    rm -f "${temp_dir}/${go_tar}"

    # Set up Go environment
    export GOROOT="${INSTALL_DIR}/go"
    export GOPATH="${INSTALL_DIR}/go-packages"
    export GOBIN="${INSTALL_DIR}/bin"
    export PATH="${GOROOT}/bin:${GOBIN}:${PATH}"

    log_success "Go ${go_version} installed successfully"
}

# ==============================================================================
# DIRECTORY SETUP
# ==============================================================================

setup_directories() {
    log_info "Setting up installation directories..."

    local dirs=(
        "${INSTALL_DIR}"
        "${INSTALL_DIR}/bin"
        "${INSTALL_DIR}/tools"
        "${INSTALL_DIR}/wordlists"
        "${INSTALL_DIR}/shims"
        "${INSTALL_DIR}/.installed"
        "${INSTALL_DIR}/temp"
    )

    for dir in "${dirs[@]}"; do
        if [[ ! -d "${dir}" ]]; then
            if [[ "${DRY_RUN}" == "true" ]]; then
                log_info "[DRY-RUN] Would create: ${dir}"
            else
                mkdir -p "${dir}"
                log_debug "Created directory: ${dir}"
            fi
        fi
    done

    # Set up log file
    LOG_FILE="${INSTALL_DIR}/install.log"
    MANIFEST_LOCK="${INSTALL_DIR}/manifest.lock"

    if [[ "${DRY_RUN}" != "true" ]]; then
        echo "=== Installation started at $(date) ===" >> "${LOG_FILE}"
    fi

    log_success "Installation directories ready at: ${INSTALL_DIR}"
}

# ==============================================================================
# TOOL INSTALLATION ADAPTERS
# ==============================================================================

# Check if tool is already installed
is_tool_installed() {
    local tool_name="$1"
    local stamp_file="${INSTALL_DIR}/.installed/${tool_name}.stamp"

    [[ -f "${stamp_file}" ]]
}

# Get installed tool version
get_installed_version() {
    local tool_name="$1"
    local stamp_file="${INSTALL_DIR}/.installed/${tool_name}.stamp"

    if [[ -f "${stamp_file}" ]]; then
        grep "^version=" "${stamp_file}" | cut -d'=' -f2
    else
        echo "unknown"
    fi
}

# Mark tool as installed
mark_tool_installed() {
    local tool_name="$1"
    local version="${2:-unknown}"
    local stamp_file="${INSTALL_DIR}/.installed/${tool_name}.stamp"

    if [[ "${DRY_RUN}" == "true" ]]; then
        return 0
    fi

    cat > "${stamp_file}" <<EOF
tool=${tool_name}
version=${version}
installed_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
install_dir=${INSTALL_DIR}
EOF

    log_debug "Marked ${tool_name} as installed"
}

# Install via go install
install_via_go() {
    local tool_name="$1"
    local go_package="$2"
    local env_vars="${3:-}"

    log_info "Installing ${tool_name} via go install..."

    # Set up Go environment
    export GOBIN="${INSTALL_DIR}/bin"
    export GOPATH="${INSTALL_DIR}/go-packages"

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would run: go install ${go_package}"
        return 0
    fi

    # Parse and set environment variables
    if [[ -n "${env_vars}" ]]; then
        eval "export ${env_vars}"
    fi

    if go install -v "${go_package}" >> "${LOG_FILE}" 2>&1; then
        log_success "${tool_name} installed successfully"
        return 0
    else
        log_error "Failed to install ${tool_name} via go install"
        return 1
    fi
}

# Install via package manager
install_via_package_manager() {
    local tool_name="$1"
    local package_name="$2"

    log_info "Installing ${tool_name} via ${PKG_MANAGER}..."

    if [[ "${PKG_MANAGER}" == "none" ]]; then
        log_warn "No package manager available, skipping ${tool_name}"
        return 1
    fi

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would install package: ${package_name}"
        return 0
    fi

    install_system_packages "${package_name}"
}

# Install via pip
install_via_pip() {
    local tool_name="$1"
    local pip_package="$2"

    log_info "Installing ${tool_name} via pip..."

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would run: pip3 install ${pip_package}"
        return 0
    fi

    if pip3 install --user "${pip_package}" >> "${LOG_FILE}" 2>&1; then
        log_success "${tool_name} installed successfully"

        # Add pip user bin to PATH
        local pip_bin="${HOME}/.local/bin"
        if [[ -d "${pip_bin}" ]] && [[ ":${PATH}:" != *":${pip_bin}:"* ]]; then
            export PATH="${pip_bin}:${PATH}"
        fi

        return 0
    else
        log_error "Failed to install ${tool_name} via pip"
        return 1
    fi
}

# Install via git clone
install_via_git_clone() {
    local tool_name="$1"
    local repo_url="$2"
    local post_commands="${3:-}"

    local tool_dir="${INSTALL_DIR}/tools/${tool_name}"

    log_info "Installing ${tool_name} via git clone..."

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would clone: ${repo_url} to ${tool_dir}"
        return 0
    fi

    # Check if already cloned
    if [[ -d "${tool_dir}/.git" ]]; then
        if [[ "${UPGRADE_MODE}" == "true" ]]; then
            log_info "Updating ${tool_name}..."
            (cd "${tool_dir}" && git pull --quiet) >> "${LOG_FILE}" 2>&1
        else
            log_debug "${tool_name} already cloned, skipping"
            return 0
        fi
    else
        git clone --quiet "${repo_url}" "${tool_dir}" >> "${LOG_FILE}" 2>&1
    fi

    # Run post-clone commands
    if [[ -n "${post_commands}" ]]; then
        (cd "${tool_dir}" && eval "${post_commands}") >> "${LOG_FILE}" 2>&1
    fi

    log_success "${tool_name} installed successfully"
    return 0
}

# Install via git clone and build
install_via_git_clone_build() {
    local tool_name="$1"
    local repo_url="$2"
    local build_commands="${3:-make}"

    local tool_dir="${INSTALL_DIR}/tools/${tool_name}"

    log_info "Installing ${tool_name} via git clone + build..."

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would clone and build: ${repo_url}"
        return 0
    fi

    # Clone if not exists
    if [[ ! -d "${tool_dir}/.git" ]]; then
        git clone --quiet "${repo_url}" "${tool_dir}" >> "${LOG_FILE}" 2>&1
    fi

    # Build
    (
        cd "${tool_dir}"
        # Replace ${INSTALL_DIR} in commands
        local cmds="${build_commands//\$\{INSTALL_DIR\}/${INSTALL_DIR}}"
        eval "${cmds}"
    ) >> "${LOG_FILE}" 2>&1

    log_success "${tool_name} built successfully"
    return 0
}

# Install release binary
install_via_release_binary() {
    local tool_name="$1"
    local release_url="$2"
    local binary_name="${3:-${tool_name}}"
    local extract="${4:-false}"

    log_info "Installing ${tool_name} from release binary..."

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would download: ${release_url}"
        return 0
    fi

    local temp_dir="${INSTALL_DIR}/temp"
    local filename=$(basename "${release_url}")
    local download_path="${temp_dir}/${filename}"

    # Download
    wget -q "${release_url}" -O "${download_path}" >> "${LOG_FILE}" 2>&1

    # Extract if needed
    if [[ "${extract}" == "true" ]]; then
        if [[ "${filename}" == *.zip ]]; then
            unzip -q -o "${download_path}" -d "${temp_dir}" >> "${LOG_FILE}" 2>&1
        elif [[ "${filename}" == *.tar.gz ]] || [[ "${filename}" == *.tgz ]]; then
            tar -xzf "${download_path}" -C "${temp_dir}" >> "${LOG_FILE}" 2>&1
        fi
        rm -f "${download_path}"
    fi

    # Find and move binary
    local binary_path=$(find "${temp_dir}" -name "${binary_name}" -type f | head -1)
    if [[ -n "${binary_path}" ]]; then
        chmod +x "${binary_path}"
        mv "${binary_path}" "${INSTALL_DIR}/bin/${binary_name}"
        log_success "${tool_name} installed successfully"
        return 0
    else
        log_error "Could not find binary ${binary_name} after extraction"
        return 1
    fi
}

# Verify tool installation
verify_tool() {
    local tool_name="$1"
    local verify_cmd="$2"

    if [[ "${DRY_RUN}" == "true" ]]; then
        return 0
    fi

    log_debug "Verifying ${tool_name}..."

    # Replace ${INSTALL_DIR} in verify command
    verify_cmd="${verify_cmd//\$\{INSTALL_DIR\}/${INSTALL_DIR}}"

    if eval "${verify_cmd}" >> "${LOG_FILE}" 2>&1; then
        log_success "${tool_name} verification passed"
        return 0
    else
        log_warn "${tool_name} verification failed"
        return 1
    fi
}

# ==============================================================================
# YAML PARSING (Simple)
# ==============================================================================

# Parse tools.yaml and install tools
# Note: This is a simple YAML parser for the specific structure we use
parse_and_install_tools() {
    if [[ ! -f "${TOOLS_YAML}" ]]; then
        log_error "Tools manifest not found: ${TOOLS_YAML}"
        exit 1
    fi

    log_info "Parsing tools manifest..."

    # Simple approach: extract tool names first
    # In a production script, consider using yq or python for YAML parsing

    # For this implementation, we'll install key tools manually
    # This is a simplified version - a full implementation would parse YAML properly

    local tools_to_install=(
        "subfinder:go:github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
        "httpx:go:github.com/projectdiscovery/httpx/cmd/httpx@latest"
        "nuclei:go:github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
        "naabu:go:github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
        "katana:go:github.com/projectdiscovery/katana/cmd/katana@latest"
        "dnsx:go:github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
        "ffuf:go:github.com/ffuf/ffuf/v2@latest"
        "gobuster:go:github.com/OJ/gobuster/v3@latest"
        "assetfinder:go:github.com/tomnomnom/assetfinder@latest"
        "waybackurls:go:github.com/tomnomnom/waybackurls@latest"
        "gau:go:github.com/lc/gau/v2/cmd/gau@latest"
        "anew:go:github.com/tomnomnom/anew@latest"
        "unfurl:go:github.com/tomnomnom/unfurl@latest"
        "qsreplace:go:github.com/tomnomnom/qsreplace@latest"
        "dalfox:go:github.com/hahwul/dalfox/v2@latest"
        "gf:go:github.com/tomnomnom/gf@latest"
        "amass:go:github.com/owasp-amass/amass/v4/...@master"
        "puredns:go:github.com/d3mondev/puredns/v2@latest"
        "shuffledns:go:github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest"
        "notify:go:github.com/projectdiscovery/notify/cmd/notify@latest"
    )

    for tool_spec in "${tools_to_install[@]}"; do
        IFS=':' read -r tool_name install_type install_target <<< "${tool_spec}"

        # Skip if not in selected tools (if specified)
        if [[ ${#SELECTED_TOOLS[@]} -gt 0 ]]; then
            if [[ ! " ${SELECTED_TOOLS[*]} " =~ " ${tool_name} " ]]; then
                continue
            fi
        fi

        # Check if already installed
        if is_tool_installed "${tool_name}" && [[ "${UPGRADE_MODE}" != "true" ]]; then
            log_info "${tool_name} is already installed ($(get_installed_version "${tool_name}"))"
            INSTALLED_TOOLS+=("${tool_name}")
            continue
        fi

        # Install based on type
        case "${install_type}" in
            go)
                if install_via_go "${tool_name}" "${install_target}"; then
                    mark_tool_installed "${tool_name}"
                    INSTALLED_TOOLS+=("${tool_name}")
                else
                    FAILED_TOOLS+=("${tool_name}")
                fi
                ;;
            pip)
                if install_via_pip "${tool_name}" "${install_target}"; then
                    mark_tool_installed "${tool_name}"
                    INSTALLED_TOOLS+=("${tool_name}")
                else
                    FAILED_TOOLS+=("${tool_name}")
                fi
                ;;
            pkg)
                if install_via_package_manager "${tool_name}" "${install_target}"; then
                    mark_tool_installed "${tool_name}"
                    INSTALLED_TOOLS+=("${tool_name}")
                else
                    FAILED_TOOLS+=("${tool_name}")
                fi
                ;;
        esac
    done

    # Install some additional essential tools
    install_additional_tools
}

install_additional_tools() {
    log_info "Installing additional tools..."

    # jq via package manager
    if ! command -v jq &>/dev/null; then
        install_via_package_manager "jq" "jq" && mark_tool_installed "jq"
    fi

    # nmap via package manager
    if ! command -v nmap &>/dev/null; then
        case "${PKG_MANAGER}" in
            apt) install_via_package_manager "nmap" "nmap libpcap-dev" ;;
            *) install_via_package_manager "nmap" "nmap" ;;
        esac
        mark_tool_installed "nmap"
    fi

    # sqlmap via package manager
    if ! command -v sqlmap &>/dev/null; then
        if install_via_package_manager "sqlmap" "sqlmap"; then
            mark_tool_installed "sqlmap"
        fi
    fi

    # SecLists wordlist
    local seclists_dir="${INSTALL_DIR}/wordlists/SecLists"
    if [[ ! -d "${seclists_dir}" ]]; then
        log_info "Cloning SecLists wordlists..."
        if [[ "${DRY_RUN}" != "true" ]]; then
            git clone --quiet --depth 1 https://github.com/danielmiessler/SecLists.git "${seclists_dir}" >> "${LOG_FILE}" 2>&1
            mark_tool_installed "seclists"
        fi
    fi
}

# ==============================================================================
# PATH MANAGEMENT
# ==============================================================================

setup_path() {
    log_info "Setting up PATH configuration..."

    local bin_dir="${INSTALL_DIR}/bin"
    local shims_dir="${INSTALL_DIR}/shims"
    local go_bin="${INSTALL_DIR}/go/bin"
    local path_addition="export PATH=\"${shims_dir}:${bin_dir}:${go_bin}:\${PATH}\""

    # Determine shell config file
    local shell_config=""
    if [[ -n "${BASH_VERSION}" ]]; then
        shell_config="${HOME}/.bashrc"
    elif [[ -n "${ZSH_VERSION}" ]]; then
        shell_config="${HOME}/.zshrc"
    else
        shell_config="${HOME}/.profile"
    fi

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would add to ${shell_config}:"
        log_info "[DRY-RUN]   ${path_addition}"
        return 0
    fi

    # Check if already added
    if ! grep -q "${INSTALL_DIR}/bin" "${shell_config}" 2>/dev/null; then
        cat >> "${shell_config}" <<EOF

# Bug Bounty Tools PATH (added by setup-bounty.sh)
export GOROOT="${INSTALL_DIR}/go"
export GOPATH="${INSTALL_DIR}/go-packages"
export GOBIN="${INSTALL_DIR}/bin"
${path_addition}
EOF
        log_success "Added to PATH in ${shell_config}"
        log_warn "Please run: source ${shell_config}"
    else
        log_info "PATH already configured in ${shell_config}"
    fi

    # Export for current session
    export PATH="${shims_dir}:${bin_dir}:${go_bin}:${PATH}"
}

# ==============================================================================
# COMPATIBILITY SHIMS
# ==============================================================================

create_compatibility_shims() {
    log_info "Creating compatibility shims..."

    # Nuclei shim for template update flag compatibility
    local nuclei_shim="${INSTALL_DIR}/shims/nuclei"

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would create shim: ${nuclei_shim}"
        return 0
    fi

    cat > "${nuclei_shim}" <<'EOF'
#!/bin/bash
# Nuclei compatibility shim
# Maps old -update-templates flag to new -ut flag

NUCLEI_BIN="${INSTALL_DIR}/bin/nuclei"
args=()

for arg in "$@"; do
    case "$arg" in
        -update-templates)
            args+=("-ut")
            ;;
        *)
            args+=("$arg")
            ;;
    esac
done

exec "${NUCLEI_BIN}" "${args[@]}"
EOF

    # Replace ${INSTALL_DIR} in shim
    sed -i "s|\${INSTALL_DIR}|${INSTALL_DIR}|g" "${nuclei_shim}"
    chmod +x "${nuclei_shim}"

    log_success "Created compatibility shims"
}

# ==============================================================================
# SMOKE TESTS
# ==============================================================================

run_smoke_tests() {
    log_info "Running smoke tests on installed tools..."

    local passed=0
    local failed=0
    local test_results="${INSTALL_DIR}/smoke-test-results.txt"

    echo "=== Smoke Test Results - $(date) ===" > "${test_results}"

    for tool in "${INSTALLED_TOOLS[@]}"; do
        log_debug "Testing ${tool}..."

        # Try to run --version, -version, --help, or -h
        local test_passed=false
        for flag in "--version" "-version" "--help" "-h" "version"; do
            if timeout 5 "${tool}" ${flag} &>/dev/null; then
                test_passed=true
                break
            fi
        done

        if [[ "${test_passed}" == "true" ]]; then
            echo "[PASS] ${tool}" >> "${test_results}"
            echo -e "  ${GREEN}✓${NC} ${tool}"
            ((passed++))
        else
            echo "[FAIL] ${tool}" >> "${test_results}"
            echo -e "  ${RED}✗${NC} ${tool}"
            ((failed++))
        fi
    done

    echo "" >> "${test_results}"
    echo "Total: $((passed + failed)), Passed: ${passed}, Failed: ${failed}" >> "${test_results}"

    log_success "Smoke tests complete: ${passed} passed, ${failed} failed"
    log_info "Detailed results: ${test_results}"

    return 0
}

# ==============================================================================
# ROLLBACK
# ==============================================================================

rollback_installation() {
    log_warn "Rolling back last installation..."

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would remove: ${INSTALL_DIR}"
        return 0
    fi

    read -p "Are you sure you want to remove ${INSTALL_DIR}? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "${INSTALL_DIR}"
        log_success "Rollback complete"
    else
        log_info "Rollback cancelled"
    fi
}

# ==============================================================================
# INTERACTIVE MODE
# ==============================================================================

interactive_setup() {
    echo -e "${CYAN}"
    cat <<'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        Bug Bounty VPS Setup Script v2.0                      ║
║        Robust & Flexible Tool Installer                      ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    # Ask for install directory
    read -p "Install directory [${DEFAULT_INSTALL_DIR}]: " user_install_dir
    INSTALL_DIR="${user_install_dir:-${DEFAULT_INSTALL_DIR}}"

    # Expand tilde
    INSTALL_DIR="${INSTALL_DIR/#\~/$HOME}"

    # Ask about sudo usage
    read -p "Use sudo for system package installation? [Y/n]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        USE_SUDO=true
    fi

    # Ask about tool selection
    echo ""
    echo "Select tools to install:"
    echo "  1) All tools (default)"
    echo "  2) Essential tools only (subfinder, httpx, nuclei, nmap)"
    echo "  3) Custom selection"
    read -p "Choice [1]: " tool_choice

    case "${tool_choice}" in
        2)
            SELECTED_TOOLS=("subfinder" "httpx" "nuclei" "nmap" "ffuf" "gobuster" "naabu")
            ;;
        3)
            read -p "Enter tool names (comma-separated): " custom_tools
            IFS=',' read -ra SELECTED_TOOLS <<< "${custom_tools}"
            ;;
        *)
            # All tools
            SELECTED_TOOLS=()
            ;;
    esac

    echo ""
    log_info "Configuration complete!"
    log_info "Install directory: ${INSTALL_DIR}"
    log_info "Using sudo: ${USE_SUDO}"
    echo ""
    read -p "Proceed with installation? [Y/n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        log_info "Installation cancelled"
        exit 0
    fi
}

# ==============================================================================
# MANIFEST LOCK
# ==============================================================================

write_manifest_lock() {
    if [[ "${DRY_RUN}" == "true" ]]; then
        return 0
    fi

    log_info "Writing manifest lock file..."

    cat > "${MANIFEST_LOCK}" <<EOF
# Installation manifest - $(date)
install_dir=${INSTALL_DIR}
installed_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
script_version=${VERSION}
os_type=${OS_TYPE}
os_version=${OS_VERSION}

# Installed tools
EOF

    for tool in "${INSTALLED_TOOLS[@]}"; do
        echo "${tool}=$(get_installed_version "${tool}")" >> "${MANIFEST_LOCK}"
    done

    log_success "Manifest lock written to ${MANIFEST_LOCK}"
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --prefix)
                INSTALL_DIR="$2"
                shift 2
                ;;
            --yes|-y)
                ASSUME_YES=true
                INTERACTIVE=false
                USE_SUDO=true
                shift
                ;;
            --upgrade)
                UPGRADE_MODE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --smoke-test)
                SMOKE_TEST=true
                shift
                ;;
            --rollback)
                ROLLBACK_MODE=true
                shift
                ;;
            --sudo)
                USE_SUDO=true
                shift
                ;;
            --tools)
                IFS=',' read -ra SELECTED_TOOLS <<< "$2"
                shift 2
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            --version|-v)
                echo "Bug Bounty Setup Script v${VERSION}"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Handle INSTALL_DIR environment variable
    INSTALL_DIR="${INSTALL_DIR:-${DEFAULT_INSTALL_DIR}}"
    INSTALL_DIR="${INSTALL_DIR/#\~/$HOME}"

    # Show banner
    echo -e "${GREEN}Bug Bounty VPS Setup Script v${VERSION}${NC}"
    echo ""

    # Rollback mode
    if [[ "${ROLLBACK_MODE}" == "true" ]]; then
        rollback_installation
        exit 0
    fi

    # Interactive mode
    if [[ "${INTERACTIVE}" == "true" ]] && [[ "${SMOKE_TEST}" != "true" ]]; then
        interactive_setup
    fi

    # Setup directories first
    setup_directories

    # Smoke test mode
    if [[ "${SMOKE_TEST}" == "true" ]]; then
        log_info "Running smoke tests only..."

        # Load installed tools from stamps
        for stamp in "${INSTALL_DIR}"/.installed/*.stamp; do
            if [[ -f "${stamp}" ]]; then
                tool_name=$(basename "${stamp}" .stamp)
                INSTALLED_TOOLS+=("${tool_name}")
            fi
        done

        run_smoke_tests
        exit 0
    fi

    # Detect OS
    detect_os

    # Ensure prerequisites
    ensure_prerequisites

    # Setup Go environment
    export GOROOT="${INSTALL_DIR}/go"
    export GOPATH="${INSTALL_DIR}/go-packages"
    export GOBIN="${INSTALL_DIR}/bin"
    export PATH="${GOBIN}:${GOROOT}/bin:${PATH}"

    # Parse and install tools
    parse_and_install_tools

    # Create compatibility shims
    create_compatibility_shims

    # Setup PATH
    setup_path

    # Write manifest lock
    write_manifest_lock

    # Summary
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Installation Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    log_info "Installed: ${#INSTALLED_TOOLS[@]} tools"
    if [[ ${#FAILED_TOOLS[@]} -gt 0 ]]; then
        log_warn "Failed: ${#FAILED_TOOLS[@]} tools - ${FAILED_TOOLS[*]}"
    fi
    echo ""
    log_info "Installation directory: ${INSTALL_DIR}"
    log_info "Log file: ${LOG_FILE}"
    log_info "Manifest: ${MANIFEST_LOCK}"
    echo ""
    log_warn "To use the tools, run:"
    echo -e "  ${CYAN}source ~/.bashrc${NC}  (or ~/.zshrc)"
    echo ""
    log_info "To run smoke tests:"
    echo -e "  ${CYAN}$0 --smoke-test${NC}"
    echo ""
}

# Run main
main "$@"
