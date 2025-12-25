#!/bin/bash

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Global Configuration and Failure Log ---
# Log file to store installation failures
FAILED_TOOLS_LOG="/root/OK-VPS/tools_installation_failures.log"

# --- Logging Functions ---
log_start() {
    echo -e "${BLUE}[$1] ${YELLOW}$2 installation in progress ...${NC}"
}

log_done() {
    echo -e "${BLUE}[$1] ${GREEN}$2 installation is done!${NC}\n"
}

log_skip() {
    echo -e "${BLUE}[$1] ${GREEN}$2 is already installed. Skipping installation.${NC}\n"
}

log_fail() {
    local SECTION=$1
    local TOOL=$2
    local REASON=$3
    # Log failure to console
    echo -e "${BLUE}[$SECTION] ${RED}$TOOL installation failed. Continuing with next tool. Reason: $REASON${NC}"
    # Log failure to file for later inspection
    echo "$SECTION|$TOOL|$REASON" >> "$FAILED_TOOLS_LOG"
    echo "" # Add a newline for clean output separation
}

# --- Failure Display Function (for -f) ---
display_failures() {
    # Check if the log file exists and is not empty
    if [ ! -s "$FAILED_TOOLS_LOG" ]; then
        echo -e "\n${GREEN}=====================================================${NC}"
        echo -e "${GREEN}No installation failures were recorded in the last run!${NC}"
        echo -e "${GREEN}=====================================================${NC}"
        exit 0
    fi

    echo -e "\n${RED}========================================================================${NC}"
    echo -e "${RED} FAILED TOOLS SUMMARY (Run './okvps.sh' to re-install) ${NC}"
    echo -e "${RED}========================================================================${NC}"
    
    # Header
    printf "%-30s %-20s %s\n" "SECTION" "TOOL NAME" "FAILURE REASON"
    echo "------------------------------------------------------------------------"

    # Read and format failures
    while IFS='|' read -r section tool reason; do
        # Truncate and sanitize reason for display
        display_reason=$(echo "$reason" | cut -c 1-50)
        printf "%-30s %-20s %s\n" "$section" "$tool" "$display_reason"
    done < "$FAILED_TOOLS_LOG"

    echo -e "${RED}========================================================================${NC}"
    echo -e "${YELLOW}Note: These tools failed. Review system dependencies (e.g., C libraries, Go/Python versions) or check the source repository for detailed errors.${NC}"
    exit 0
}

# --- Help Display Function (for -h) ---
display_help() {
    echo -e "\n${GREEN}=====================================================${NC}"
    echo -e "${YELLOW}Usage: ./your_script_name.sh [OPTION]${NC}"
    echo -e "${GREEN}=====================================================${NC}"
    echo -e "  (No option) : Start or continue the full tool installation process."
    echo -e "  ${YELLOW}-f${NC}            : Display a summary of all tools that failed during the last installation attempt."
    echo -e "  ${YELLOW}-h${NC}            : Show this help message and exit."
    echo -e "\n${YELLOW}Note: Before running again, ensure dependencies like 'Go' and 'Python3-pip' are functional.${NC}"
    exit 0
}

# --- Argument Check (Implementing the Flags -f and -h) ---
case "$1" in
    "-f")
        display_failures
        ;;
    "-h")
        display_help
        ;;
    "")
        # No flag provided, proceed with installation
        ;;
    *)
        echo -e "\n${RED}Error: Unknown option '$1'. Use -h for help.${NC}"
        display_help
        ;;
esac

# --- ROOT CHECK (Ensures the script is run with necessary privileges on Debian/Ubuntu) ---
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: Ei script-ti chalanor jonno root privilege (sudo) proyojon.${NC}"
   echo -e "${RED}Please run this script as root or with sudo: sudo ./your_script_name.sh${NC}"
   exit 1
fi
# --- End of ROOT CHECK ---


# --- Initial Setup and Dependencies (Crucial for a clean install) ---
echo -e "${BLUE}Starting initial setup and dependency installation...${NC}"

# Clear failure log file at the start of a new installation run
> "$FAILED_TOOLS_LOG"

# Create necessary directories
mkdir -p /root/OK-VPS/tools /root/OK-VPS/tools/file /root/wordlist /root/templates

clear

# Install core packages (Updated for wider Debian/Ubuntu compatibility: added libpcap-dev, ruby, ruby-dev, python3-dev)
log_start "CORE" "Basic dependencies: git, curl, wget, build-essential, libpcap-dev, python3, ruby"
if apt update > /dev/null 2>&1 && apt install -y git curl wget unzip make build-essential python3-pip apt-transport-https jq nmap parallel libpcap-dev ruby ruby-dev python3-dev > /dev/null 2>&1; then
    log_done "CORE" "Basic dependencies"
else
    log_fail "CORE" "Basic dependencies" "Apt install failed (Network/Repository issue or missing core packages)"
fi


# GoLang Installation and Configuration (Checking if 'go' command exists)
log_start "CORE" "Golang"
if command -v go &> /dev/null; then
    log_skip "CORE" "Golang"
else
    if (
        echo -e "${YELLOW}Golang not found, installing Go 1.22.2...${NC}" &&
        cd /root/OK-VPS/tools/file &&
        wget -q https://go.dev/dl/go1.22.2.linux-amd64.tar.gz &&
        tar -zxvf go1.22.2.linux-amd64.tar.gz -C /usr/local/ > /dev/null 2>&1 &&
        rm -f go1.22.2.linux-amd64.tar.gz &&
        update-alternatives --install "/usr/bin/go" "go" "/usr/local/go/bin/go" 0 &&
        update-alternatives --set go /usr/local/go/bin/go
    ); then
        # Ensure GOPATH directory exists regardless of installation path
        mkdir -p ~/.go

        # Update PATH for the current session (Always required for subsequent GO tools in this script)
        export GOROOT=/usr/local/go
        export GOPATH=~/.go
        export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

        # Append PATH variables to .bashrc for persistence (Use grep -q to prevent duplication)
        grep -q "export GOROOT" ~/.bashrc || echo "export GOROOT=/usr/local/go" >> ~/.bashrc
        grep -q "export GOPATH" ~/.bashrc || echo "export GOPATH=~/.go" >> ~/.bashrc
        # Safely replace/add the PATH export line
        sed -i '/export PATH.*\$GOPATH\/bin/d' ~/.bashrc
        echo "export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin" >> ~/.bashrc
        source ~/.bashrc # Load new path immediately
        log_done "CORE" "Golang"
    else
        log_fail "CORE" "Golang" "Golang installation failed"
    fi
fi
# --- End of Initial Setup ---

SUBDOMAINS_ENUMERATION () {
    log_start "SUBDOMAINS ENUMERATION" "Subfinder"
    if ! command -v subfinder &> /dev/null; then
        if GO111MODULE=on go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/subfinder /usr/local/bin/; then
            log_done "SUBDOMAINS ENUMERATION" "Subfinder"
        else
            log_fail "SUBDOMAINS ENUMERATION" "Subfinder" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "Subfinder"
    fi

    log_start "SUBDOMAINS ENUMERATION" "Assetfinder"
    if ! command -v assetfinder &> /dev/null; then
        if go install github.com/tomnomnom/assetfinder@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/assetfinder /usr/local/bin/; then
            log_done "SUBDOMAINS ENUMERATION" "Assetfinder"
        else
            log_fail "SUBDOMAINS ENUMERATION" "Assetfinder" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "Assetfinder"
    fi

    log_start "SUBDOMAINS ENUMERATION" "Findomain"
    if ! command -v findomain &> /dev/null; then
        if cd /root/OK-VPS/tools/file && curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux-i386.zip > /dev/null 2>&1 && unzip findomain-linux-i386.zip > /dev/null 2>&1 && chmod +x findomain && cp findomain /usr/bin/ && chmod +x /usr/bin/findomain; then
            log_done "SUBDOMAINS ENUMERATION" "Findomain"
        else
            log_fail "SUBDOMAINS ENUMERATION" "Findomain" "Binary download/setup failed"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "Findomain"
    fi

    log_start "SUBDOMAINS ENUMERATION" "Github-subdomains"
    if ! command -v github-subdomains &> /dev/null; then
        if go install github.com/gwen001/github-subdomains@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/github-subdomains /usr/local/bin/; then
            log_done "SUBDOMAINS ENUMERATION" "Github-subdomains"
        else
            log_fail "SUBDOMAINS ENUMERATION" "Github-subdomains" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "Github-subdomains"
    fi

    log_start "SUBDOMAINS ENUMERATION" "Amass"
    if ! command -v amass &> /dev/null; then
        if (
            go install -v github.com/owasp-amass/amass/v4/...@master > /dev/null 2>&1 && 
            ln -s -f ~/go/bin/amass /usr/local/bin/ && 
            mkdir -p ~/.config/amass && 
            cd ~/.config/amass && 
            wget -q https://raw.githubusercontent.com/owasp-amass/amass/master/examples/config.yaml && 
            wget -q https://raw.githubusercontent.com/owasp-amass/amass/master/examples/datasources.yaml
        ); then
            log_done "SUBDOMAINS ENUMERATION" "Amass"
        else
            log_fail "SUBDOMAINS ENUMERATION" "Amass" "Go install/Config download failed"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "Amass"
    fi

    log_start "SUBDOMAINS ENUMERATION" "Lilly"
    if [ ! -d "/root/OK-VPS/tools/Lilly" ]; then
        if cd /root/OK-VPS/tools && git clone https://github.com/Dheerajmadhukar/Lilly.git > /dev/null 2>&1 && cd Lilly && chmod +x lilly.sh; then
            log_done "SUBDOMAINS ENUMERATION" "Lilly"
        else
            log_fail "SUBDOMAINS ENUMERATION" "Lilly" "Git clone failed (Network/Repository issue)"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "Lilly"
    fi

    log_start "SUBDOMAINS ENUMERATION" "Crobat"
    if ! command -v crobat &> /dev/null; then
        if go install github.com/cgboal/sonarsearch/cmd/crobat@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/crobat /usr/local/bin/; then
            log_done "SUBDOMAINS ENUMERATION" "Crobat"
        else
            log_fail "SUBDOMAINS ENUMERATION" "Crobat" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "Crobat"
    fi

    log_start "SUBDOMAINS ENUMERATION" "Sudomy"
    if [ ! -d "/root/OK-VPS/tools/Sudomy" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone --recursive https://github.com/screetsec/Sudomy.git > /dev/null 2>&1 &&
            cd Sudomy &&
            pip3 install -r requirements.txt > /dev/null 2>&1 && # FIXED: Using pip3
            apt install -y npm chromium phantomjs > /dev/null 2>&1 && 
            npm install -g wappalyzer wscat > /dev/null 2>&1 &&
            cp -f sudomy /usr/local/bin/ &&
            cp -f sudomy.api /usr/local/bin/ &&
            cp -f slack.conf /usr/local/bin/ &&
            cp -f sudomy.conf /usr/local/bin/ &&
            ln -s -f /root/OK-VPS/tools/Sudomy/sudomy /usr/local/bin/
        ); then
            log_done "SUBDOMAINS ENUMERATION" "Sudomy"
        else
            log_fail "SUBDOMAINS ENUMERATION" "Sudomy" "Git/Pip/NPM install failed (Complex dependencies)"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "Sudomy"
    fi

    log_start "SUBDOMAINS ENUMERATION" "AltDns"
    if [ ! -d "/root/OK-VPS/tools/file/altdns" ]; then
        if (
            cd /root/OK-VPS/tools/file && 
            git clone https://github.com/infosec-au/altdns.git > /dev/null 2>&1 && # Added redirection for clone output
            cd altdns &&
            pip3 install --upgrade pip setuptools pyopenssl requests urllib3 cachecontrol > /dev/null 2>&1 && # FIXED: Using pip3
            pip3 install -r requirements.txt > /dev/null 2>&1 # FIXED: Using pip3
        ); then
            log_done "SUBDOMAINS ENUMERATION" "AltDns"
        else
            log_fail "SUBDOMAINS ENUMERATION" "AltDns" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "AltDns"
    fi

    log_start "SUBDOMAINS ENUMERATION" "CertCrunchy"
    if [ ! -d "/root/OK-VPS/tools/file/CertCrunchy" ]; then
        if (
            cd /root/OK-VPS/tools/file && 
            git clone https://github.com/joda32/CertCrunchy.git > /dev/null 2>&1 &&
            cd CertCrunchy &&
            pip3 install -r requirements.txt > /dev/null 2>&1
        ); then
            log_done "SUBDOMAINS ENUMERATION" "CertCrunchy"
        else
            log_fail "SUBDOMAINS ENUMERATION" "CertCrunchy" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "CertCrunchy"
    fi

    log_start "SUBDOMAINS ENUMERATION" "chaos"
    if ! command -v chaos &> /dev/null; then
        if go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/chaos /usr/local/bin/; then
            log_done "SUBDOMAINS ENUMERATION" "chaos"
        else
            log_fail "SUBDOMAINS ENUMERATION" "chaos" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "chaos"
    fi

    log_start "SUBDOMAINS ENUMERATION" "shodan-cli"
    if ! command -v shodan &> /dev/null; then
        if apt install -y python3-shodan > /dev/null 2>&1 && shodan init Dw9DTE811cfQ6j59jGLfVAWAMDr0MCTT > /dev/null 2>&1; then
            log_done "SUBDOMAINS ENUMERATION" "shodan-cli"
        else
            log_fail "SUBDOMAINS ENUMERATION" "shodan-cli" "Apt install failed (Package issue)"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "shodan-cli"
    fi

    log_start "SUBDOMAINS ENUMERATION" "gotator"
    if ! command -v gotator &> /dev/null; then
        if go install github.com/Josue87/gotator@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/gotator /usr/local/bin/; then
            log_done "SUBDOMAINS ENUMERATION" "gotator"
        else
            log_fail "SUBDOMAINS ENUMERATION" "gotator" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "gotator"
    fi

    log_start "SUBDOMAINS ENUMERATION" "ctfr"
    if [ ! -d "/root/OK-VPS/tools/ctfr" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/UnaPibaGeek/ctfr.git &&
            cd ctfr/ &&
            pip3 install -r requirements.txt > /dev/null 2>&1
        ); then
            log_done "SUBDOMAINS ENUMERATION" "ctfr"
        else
            log_fail "SUBDOMAINS ENUMERATION" "ctfr" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "ctfr"
    fi

    log_start "SUBDOMAINS ENUMERATION" "cero"
    if ! command -v cero &> /dev/null; then
        if go install github.com/glebarez/cero@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/cero /usr/local/bin/; then
            log_done "SUBDOMAINS ENUMERATION" "cero"
        else
            log_fail "SUBDOMAINS ENUMERATION" "cero" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "cero"
    fi

    log_start "SUBDOMAINS ENUMERATION" "AnalyticsRelationships"
    if [ ! -d "/root/OK-VPS/tools/AnalyticsRelationships" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/Josue87/AnalyticsRelationships.git > /dev/null 2>&1 &&
            cd AnalyticsRelationships &&
            go build -ldflags "-s -w" &&
            cp -f -r analyticsrelationships /usr/local/bin
        ); then
            log_done "SUBDOMAINS ENUMERATION" "AnalyticsRelationships"
        else
            log_fail "SUBDOMAINS ENUMERATION" "AnalyticsRelationships" "Go build/install failed"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "AnalyticsRelationships"
    fi

    log_start "SUBDOMAINS ENUMERATION" "knockpy"
    # knockpy is hard to check for, using file check
    if [ ! -d "/root/OK-VPS/tools/file/knock-5.4.0" ]; then
        if (
            cd /root/OK-VPS/tools/file && 
            wget -q https://github.com/guelfoweb/knock/archive/refs/tags/5.4.0.zip &&
            unzip -q 5.4.0.zip &&
            cd knock-5.4.0 &&
            python3 setup.py install > /dev/null 2>&1 &&
            knockpy --set apikey-virustotal=fbbb048214f36feb32fcf7e8aa262c26b2dfe5051d02de7d85da6b3acbbed778 > /dev/null 2>&1
        ); then
            log_done "SUBDOMAINS ENUMERATION" "knockpy"
        else
            log_fail "SUBDOMAINS ENUMERATION" "knockpy" "Python setup/install failed (Dependency/API config)"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "knockpy"
    fi

    log_start "SUBDOMAINS ENUMERATION" "Censys-subdomain-finder"
    if [ ! -d "/root/OK-VPS/tools/censys-subdomain-finder" ]; then
        if (
            cd /root/OK-VPS/tools &&
            export CENSYS_API_ID=303b2554-31b0-4e2d-a036-c869f23bfb76 &&
            export CENSYS_API_SECRET=sB8T2K8en7LW6GHOkKPOfEDVpdmaDj6t &&
            git clone https://github.com/christophetd/censys-subdomain-finder.git > /dev/null 2>&1 &&
            cd censys-subdomain-finder &&
            apt install -y python3.8-venv > /dev/null 2>&1 &&
            python3 -m venv venv &&
            source venv/bin/activate &&
            pip3 install -r requirements.txt > /dev/null 2>&1 # FIXED: Using pip3
        ); then
            log_done "SUBDOMAINS ENUMERATION" "Censys-subdomain-finder"
        else
            log_fail "SUBDOMAINS ENUMERATION" "Censys-subdomain-finder" "Pip3/Venv setup failed"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "Censys-subdomain-finder"
    fi

    log_start "SUBDOMAINS ENUMERATION" "quickcert"
    if ! command -v quickcert &> /dev/null; then
        if GO111MODULE=on go install -v github.com/c3l3si4n/quickcert@HEAD > /dev/null 2>&1 && ln -s -f ~/go/bin/quickcert /usr/local/bin/; then
            log_done "SUBDOMAINS ENUMERATION" "quickcert"
        else
            log_fail "SUBDOMAINS ENUMERATION" "quickcert" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "SUBDOMAINS ENUMERATION" "quickcert"
    fi
}

DNS_RESOLVER () {
    log_start "DNS RESOLVER" "MassDNS"
    if ! command -v massdns &> /dev/null; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/blechschmidt/massdns.git > /dev/null 2>&1 &&
            cd massdns &&
            make > /dev/null 2>&1 &&
            make install > /dev/null 2>&1 &&
            ln -s -f /root/OK-VPS/tools/massdns/bin/massdns /usr/local/bin/
        ); then
            log_done "DNS RESOLVER" "MassDNS"
        else
            log_fail "DNS RESOLVER" "MassDNS" "Make/Compilation failed (Need libpcap-dev? - now in CORE)"
        fi
    else
        log_skip "DNS RESOLVER" "MassDNS"
    fi

    log_start "DNS RESOLVER" "dnsx"
    if ! command -v dnsx &> /dev/null; then
        if GO111MODULE=on go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/dnsx /usr/local/bin/; then
            log_done "DNS RESOLVER" "dnsx"
        else
            log_fail "DNS RESOLVER" "dnsx" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "DNS RESOLVER" "dnsx"
    fi

    log_start "DNS RESOLVER" "PureDNS"
    if ! command -v puredns &> /dev/null; then
        if GO111MODULE=on go install github.com/d3mondev/puredns/v2@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/puredns /usr/local/bin; then
            log_done "DNS RESOLVER" "PureDNS"
        else
            log_fail "DNS RESOLVER" "PureDNS" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "DNS RESOLVER" "PureDNS"
    fi

    log_start "DNS RESOLVER" "Shuffledns"
    if ! command -v shuffledns &> /dev/null; then
        if go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/shuffledns /usr/local/bin; then
            log_done "DNS RESOLVER" "Shuffledns"
        else
            log_fail "DNS RESOLVER" "Shuffledns" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "DNS RESOLVER" "Shuffledns"
    fi

    log_start "DNS RESOLVER" "DNSvalidator"
    if [ ! -d "/root/OK-VPS/tools/dnsvalidator" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/vortexau/dnsvalidator.git &&
            cd dnsvalidator &&
            python3 setup.py install > /dev/null 2>&1 &&
            pip3 install contextvars > /dev/null 2>&1 &&
            pip3 install -e . > /dev/null 2>&1 &&
            ln -s -f /root/OK-VPS/tools/dnsvalidator/dnsvalidator /usr/local/bin/
        ); then
            log_done "DNS RESOLVER" "DNSvalidator"
        else
            log_fail "DNS RESOLVER" "DNSvalidator" "Python setup/Pip3 install failed"
        fi
    else
        log_skip "DNS RESOLVER" "DNSvalidator"
    fi

    log_start "DNS RESOLVER" "mapcidr"
    if ! command -v mapcidr &> /dev/null; then
        if go install -v github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/mapcidr /usr/local/bin/; then
            log_done "DNS RESOLVER" "mapcidr"
        else
            log_fail "DNS RESOLVER" "mapcidr" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "DNS RESOLVER" "mapcidr"
    fi

    log_start "DNS RESOLVER" "Galer"
    if ! command -v galer &> /dev/null; then
        if GO111MODULE=on go install -v github.com/dwisiswant0/galer@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/galer /usr/local/bin/; then
            log_done "DNS RESOLVER" "Galer"
        else
            log_fail "DNS RESOLVER" "Galer" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "DNS RESOLVER" "Galer"
    fi

    log_start "DNS RESOLVER" "Haktrails"
    if ! command -v haktrails &> /dev/null; then
        if (
            GO111MODULE=on go install -v github.com/hakluke/haktrails@latest > /dev/null 2>&1 && 
            ln -s -f ~/go/bin/haktrails /usr/local/bin/ && 
            mkdir -p ~/.config/haktools && 
            touch ~/.config/haktools/haktrails-config.yml
        ); then
            log_done "DNS RESOLVER" "Haktrails"
        else
            log_fail "DNS RESOLVER" "Haktrails" "Go install/Config setup failed"
        fi
    else
        log_skip "DNS RESOLVER" "Haktrails"
    fi
}

VISUAL_tools () {
    log_start "VISUAL TOOLS" "Aquatone"
    # Aquatone is installed by binary copy, checking for binary existence
    if [ ! -f "/usr/local/bin/aquatone" ]; then
        AQUATONEVER="1.7.0" 
        if (
            cd /root/OK-VPS/tools/file &&
            wget -q https://github.com/michenriksen/aquatone/releases/download/v$AQUATONEVER/aquatone_linux_amd64_$AQUATONEVER.zip &&
            unzip -q aquatone_linux_amd64_$AQUATONEVER.zip &&
            cp -f aquatone /usr/local/bin/
        ); then
            log_done "VISUAL TOOLS" "Aquatone"
        else
            log_fail "VISUAL TOOLS" "Aquatone" "Binary download/setup failed"
        fi
    else
        log_skip "VISUAL TOOLS" "Aquatone"
    fi

    log_start "VISUAL TOOLS" "Gowitness"
    if ! command -v gowitness &> /dev/null; then
        if go install github.com/sensepost/gowitness@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/gowitness /usr/local/bin/ && chmod +x /usr/local/bin/gowitness; then
            log_done "VISUAL TOOLS" "Gowitness"
        else
            log_fail "VISUAL TOOLS" "Gowitness" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "VISUAL TOOLS" "Gowitness"
    fi
}

HTTP_PROBE () {
    log_start "HTTP PROBE" "httpx"
    if ! command -v httpx &> /dev/null; then
        if GO111MODULE=on go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/httpx /usr/local/bin/; then
            log_done "HTTP PROBE" "httpx"
        else
            log_fail "HTTP PROBE" "httpx" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "HTTP PROBE" "httpx"
    fi

    log_start "HTTP PROBE" "httprobe"
    if ! command -v httprobe &> /dev/null; then
        if go install github.com/tomnomnom/httprobe@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/httprobe /usr/local/bin/; then
            log_done "HTTP PROBE" "httprobe"
        else
            log_fail "HTTP PROBE" "httprobe" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "HTTP PROBE" "httprobe"
    fi
}

WEB_CRAWLING () {
    log_start "WEB CRAWLING" "Gospider"
    if ! command -v gospider &> /dev/null; then
        if go install github.com/jaeles-project/gospider@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/gospider /usr/local/bin/; then
            log_done "WEB CRAWLING" "Gospider"
        else
            log_fail "WEB CRAWLING" "Gospider" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "WEB CRAWLING" "Gospider"
    fi

    log_start "WEB CRAWLING" "Hakrawler"
    if ! command -v hakrawler &> /dev/null; then
        if go install github.com/hakluke/hakrawler@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/hakrawler /usr/local/bin/; then
            log_done "WEB CRAWLING" "Hakrawler"
        else
            log_fail "WEB CRAWLING" "Hakrawler" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "WEB CRAWLING" "Hakrawler"
    fi

    log_start "WEB CRAWLING" "ParamSpider"
    if [ ! -d "/root/OK-VPS/tools/paramspider" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/devanshbatham/paramspider > /dev/null 2>&1 &&
            cd paramspider &&
            apt install -y python-pip > /dev/null 2>&1 &&
            pip3 install . > /dev/null 2>&1 # FIXED: Using pip3
        ); then
            log_done "WEB CRAWLING" "ParamSpider"
        else
            log_fail "WEB CRAWLING" "ParamSpider" "Pip3 install failed (Dependency error)"
        fi
    else
        log_skip "WEB CRAWLING" "ParamSpider"
    fi

    log_start "WEB CRAWLING" "Waybackurls"
    if ! command -v waybackurls &> /dev/null; then
        if go install github.com/tomnomnom/waybackurls@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/waybackurls /usr/local/bin/; then
            log_done "WEB CRAWLING" "Waybackurls"
        else
            log_fail "WEB CRAWLING" "Waybackurls" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "WEB CRAWLING" "Waybackurls"
    fi

    log_start "WEB CRAWLING" "Gauplus"
    if ! command -v gauplus &> /dev/null; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/bp0lr/gauplus.git &&
            cd gauplus &&
            go build &&
            cp -f gauplus /usr/local/bin/
        ); then
            log_done "WEB CRAWLING" "Gauplus"
        else
            log_fail "WEB CRAWLING" "Gauplus" "Go build/install failed"
        fi
    else
        log_skip "WEB CRAWLING" "Gauplus"
    fi

    log_start "WEB CRAWLING" "Katana"
    if ! command -v katana &> /dev/null; then
        if go install github.com/projectdiscovery/katana/cmd/katana@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/katana /usr/local/bin/; then
            log_done "WEB CRAWLING" "Katana"
        else
            log_fail "WEB CRAWLING" "Katana" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "WEB CRAWLING" "Katana"
    fi

    log_start "WEB CRAWLING" "Waymore"
    if ! command -v waymore &> /dev/null; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/xnl-h4ck3r/waymore.git /opt/waymore > /dev/null 2>&1 || git -C /opt/waymore pull > /dev/null 2>&1 &&
            pip3 install -r /opt/waymore/requirements.txt > /dev/null 2>&1 &&
            ln -s -f /opt/waymore/waymore.py /usr/local/bin/waymore &&
            chmod +x /usr/local/bin/waymore
        ); then
            log_done "WEB CRAWLING" "Waymore"
        else
            log_fail "WEB CRAWLING" "Waymore" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "WEB CRAWLING" "Waymore"
    fi

    log_start "WEB CRAWLING" "Parameters"
    if ! command -v parameters &> /dev/null; then
        if go install github.com/mrco24/parameters@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/parameters /usr/local/bin/; then
            log_done "WEB CRAWLING" "Parameters"
        else
            log_fail "WEB CRAWLING" "Parameters" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "WEB CRAWLING" "Parameters"
    fi

    log_start "WEB CRAWLING" "xnLinkFinder"
    if [ ! -d "/root/OK-VPS/tools/xnLinkFinder" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/xnl-h4ck3r/xnLinkFinder.git &&
            cd xnLinkFinder &&
            python setup.py install > /dev/null 2>&1
        ); then
            log_done "WEB CRAWLING" "xnLinkFinder"
        else
            log_fail "WEB CRAWLING" "xnLinkFinder" "Python setup/install failed"
        fi
    else
        log_skip "WEB CRAWLING" "xnLinkFinder"
    fi

    log_start "WEB CRAWLING" "GF"
    if ! command -v gf &> /dev/null; then
        if go install github.com/tomnomnom/gf@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/gf /usr/local/bin/; then
            log_done "WEB CRAWLING" "GF"
        else
            log_fail "WEB CRAWLING" "GF" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "WEB CRAWLING" "GF"
    fi

    log_start "WEB CRAWLING" "GF-Patterns"
    # Assuming patterns are installed if GF directory exists
    if [ ! -d "/root/OK-VPS/tools/file/Gf-Patterns" ]; then
        if (
            mkdir -p ~/.gf &&
            cd /root/OK-VPS/tools/file &&
            git clone https://github.com/tomnomnom/gf > /dev/null 2>&1 &&
            cp -f /root/OK-VPS/tools/file/gf/examples/*.json ~/.gf &&
            git clone https://github.com/1ndianl33t/Gf-Patterns > /dev/null 2>&1 &&
            cp -f /root/OK-VPS/tools/file/Gf-Patterns/*.json ~/.gf &&
            wget -q -O ~/.gf/my-lfi.json https://raw.githubusercontent.com/mrco24/Patterns/main/my-lfi.json
        ); then
            log_done "WEB CRAWLING" "GF-Patterns"
        else
            log_fail "WEB CRAWLING" "GF-Patterns" "Git clone/Config file download failed"
        fi
    else
        log_skip "WEB CRAWLING" "GF-Patterns"
    fi

    log_start "WEB CRAWLING" "Uro"
    if ! command -v uro &> /dev/null; then
        if (
          sudo apt update
          sudo apt install pipx -y
          pipx ensurepath
          source ~/.bashrc
          # OR
          source ~/.zshrc
          pipx install uro
        ); then
            log_done "WEB CRAWLING" "Uro"
        else
            log_fail "WEB CRAWLING" "Uro" "Python setup/install failed"
        fi
    else
        log_skip "WEB CRAWLING" "Uro"
    fi

    log_start "WEB CRAWLING" "freq"
    if ! command -v freq &> /dev/null; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/takshal/freq.git > /dev/null 2>&1 &&
            cd freq &&
            mv main.go freq.go &&
            go build freq.go &&
            cp -f freq /usr/bin
        ); then
            log_done "WEB CRAWLING" "freq"
        else
            log_fail "WEB CRAWLING" "freq" "Go build/install failed"
        fi
    else
        log_skip "WEB CRAWLING" "freq"
    fi

    log_start "WEB CRAWLING" "urlfounder"
    if ! command -v urlfounder &> /dev/null; then
        if (
            cd /root/OK-VPS/tools &&
            wget -q -N -c https://github.com/chainreactors/urlfounder/releases/download/v0.0.1/urlfounder_0.0.1_linux_amd64 &&
            chmod +x urlfounder_0.0.1_linux_amd64 &&
            mv urlfounder_0.0.1_linux_amd64 urlfounder &&
            cp -f urlfounder /usr/local/bin
        ); then
            log_done "WEB CRAWLING" "urlfounder"
        else
            log_fail "WEB CRAWLING" "urlfounder" "Binary download/setup failed"
        fi
    else
        log_skip "WEB CRAWLING" "urlfounder"
    fi

    log_start "WEB CRAWLING" "cmake"
    if ! command -v cmake &> /dev/null; then
        if wget -qO- "https://cmake.org/files/v3.22/cmake-3.22.1-linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /usr/local; then
            log_done "WEB CRAWLING" "cmake"
        else
            log_fail "WEB CRAWLING" "cmake" "Binary download/setup failed"
        fi
    else
        log_skip "WEB CRAWLING" "cmake"
    fi

    log_start "WEB CRAWLING" "web-archive"
    if ! command -v web-archive &> /dev/null; then
        if go install github.com/cheggaaa/pb/v3 > /dev/null 2>&1 && go install github.com/mrco24/web-archive@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/web-archive /usr/local/bin/; then
            log_done "WEB CRAWLING" "web-archive"
        else
            log_fail "WEB CRAWLING" "web-archive" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "WEB CRAWLING" "web-archive"
    fi

    log_start "WEB CRAWLING" "otx-url"
    if ! command -v otx-url &> /dev/null; then
        if go install github.com/mrco24/otx-url@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/otx-url /usr/local/bin/; then
            log_done "WEB CRAWLING" "otx-url"
        else
            log_fail "WEB CRAWLING" "otx-url" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "WEB CRAWLING" "otx-url"
    fi
}

VULNS_SCANNER () {
    log_start "VULNERABILITY SCANNER" "Nuclei"
    if ! command -v nuclei &> /dev/null; then
        if (
            go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest > /dev/null 2>&1 && 
            ln -s -f ~/go/bin/nuclei /usr/local/bin/ &&
            go install -v github.com/xm1k3/cent@latest > /dev/null 2>&1 && 
            ln -s -f ~/go/bin/cent /usr/local/bin/ && 
            cent init > /dev/null 2>&1
        ); then
            log_done "VULNERABILITY SCANNER" "Nuclei"
        else
            log_fail "VULNERABILITY SCANNER" "Nuclei" "Go install/Cent setup failed"
        fi
    else
        log_skip "VULNERABILITY SCANNER" "Nuclei"
    fi

    log_start "VULNERABILITY SCANNER" "Jaeles"
    if ! command -v jaeles &> /dev/null; then
        if (
            cd /root/OK-VPS/tools/file && 
            wget -q https://github.com/jaeles-project/jaeles/releases/download/beta-v0.17/jaeles-v0.17-linux.zip &&
            unzip -q jaeles-v0.17-linux.zip &&
            cp -f jaeles /usr/local/bin/ &&
            cd /root/templates &&
            git clone https://github.com/projectdiscovery/fuzzing-templates.git > /dev/null 2>&1 &&
            git clone https://github.com/jaeles-project/jaeles-signatures.git > /dev/null 2>&1 &&
            git clone https://github.com/ghsec/ghsec-jaeles-signatures > /dev/null 2>&1
        ); then
            log_done "VULNERABILITY SCANNER" "Jaeles"
        else
            log_fail "VULNERABILITY SCANNER" "Jaeles" "Binary download/template clone failed"
        fi
    else
        log_skip "VULNERABILITY SCANNER" "Jaeles"
    fi

    log_start "VULNERABILITY SCANNER" "Nikto"
    if ! command -v nikto &> /dev/null; then
        if apt install -y nikto > /dev/null 2>&1; then
            log_done "VULNERABILITY SCANNER" "Nikto"
        else
            log_fail "VULNERABILITY SCANNER" "Nikto" "Apt install failed (Package issue)"
        fi
    else
        log_skip "VULNERABILITY SCANNER" "Nikto"
    fi

    log_start "VULNERABILITY SCANNER" "Xray"
    if [ ! -d "/root/OK-VPS/tools/xray" ]; then
        if (
            cd /root/OK-VPS/tools && 
            mkdir xray && 
            cd xray &&
            wget -q https://github.com/chaitin/xray/releases/download/1.9.11/xray_linux_amd64.zip &&
            unzip -q xray_linux_amd64.zip &&
            mv xray_linux_amd64 xray &&
            wget -q https://github.com/mrco24/xray-config/raw/main/n.zip &&
            unzip -q n.zip &&
            cd n &&
            cp -f -r *.yaml /root/OK-VPS/tools/xray
        ); then
            log_done "VULNERABILITY SCANNER" "Xray"
        else
            log_fail "VULNERABILITY SCANNER" "Xray" "Binary download/config failed"
        fi
    else
        log_skip "VULNERABILITY SCANNER" "Xray"
    fi

    log_start "VULNERABILITY SCANNER" "Afrog"
    if ! command -v afrog &> /dev/null; then
        if go install -v github.com/zan8in/afrog/v2/cmd/afrog@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/afrog /usr/local/bin/; then
            log_done "VULNERABILITY SCANNER" "Afrog"
        else
            log_fail "VULNERABILITY SCANNER" "Afrog" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "VULNERABILITY SCANNER" "Afrog"
    fi

    log_start "VULNERABILITY SCANNER" "POC-bomber"
    if [ ! -d "/root/OK-VPS/tools/POC-bomber" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/tr0uble-mAker/POC-bomber.git > /dev/null 2>&1 &&
            cd POC-bomber &&
            pip3 install -r requirements.txt > /dev/null 2>&1 # FIXED: Using pip3
        ); then
            log_done "VULNERABILITY SCANNER" "POC-bomber"
        else
            log_fail "VULNERABILITY SCANNER" "POC-bomber" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "VULNERABILITY SCANNER" "POC-bomber"
    fi
}

NETWORK_SCANNER () {
    log_start "NETWORK SCANNER" "Nmap"
    if ! command -v nmap &> /dev/null; then
        if apt install -y nmap libpcap-dev > /dev/null 2>&1; then
            log_done "NETWORK SCANNER" "Nmap"
        else
            log_fail "NETWORK SCANNER" "Nmap" "Apt install failed (Package issue)"
        fi
    else
        log_skip "NETWORK SCANNER" "Nmap"
    fi

    log_start "NETWORK SCANNER" "Masscan"
    if ! command -v masscan &> /dev/null; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/robertdavidgraham/masscan > /dev/null 2>&1 &&
            cd masscan &&
            make > /dev/null 2>&1 &&
            make install > /dev/null 2>&1 &&
            mv -f bin/masscan /usr/local/bin/
        ); then
            log_done "NETWORK SCANNER" "Masscan"
        else
            log_fail "NETWORK SCANNER" "Masscan" "Make/Compilation failed (libpcap-dev is installed in CORE)"
        fi
    else
        log_skip "NETWORK SCANNER" "Masscan"
    fi

    log_start "NETWORK SCANNER" "Naabu"
    if ! command -v naabu &> /dev/null; then
        if go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/naabu /usr/local/bin/; then
            log_done "NETWORK SCANNER" "Naabu"
        else
            log_fail "NETWORK SCANNER" "Naabu" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "NETWORK SCANNER" "Naabu"
    fi

    log_start "NETWORK SCANNER" "unimap"
    if ! command -v unimap &> /dev/null; then
        if (
            cd /root/OK-VPS/tools &&
            wget -q -N -c https://github.com/Edu4rdSHL/unimap/releases/download/0.5.1/unimap-linux &&
            chmod +x unimap-linux &&
            mv -f unimap-linux /usr/local/bin/unimap &&
            chmod 755 /usr/local/bin/unimap &&
            strip -s /usr/local/bin/unimap
        ); then
            log_done "NETWORK SCANNER" "unimap"
        else
            log_fail "NETWORK SCANNER" "unimap" "Binary download/setup failed"
        fi
    else
        log_skip "NETWORK SCANNER" "unimap"
    fi
}

HTTP_PARAMETER () {
    log_start "HTTP PARAMETER DISCOVERY" "Arjun"
    if ! command -v arjun &> /dev/null; then
        if pip3 install arjun > /dev/null 2>&1; then
            log_done "HTTP PARAMETER DISCOVERY" "Arjun"
        else
            log_fail "HTTP PARAMETER DISCOVERY" "Arjun" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "HTTP PARAMETER DISCOVERY" "Arjun"
    fi

    log_start "HTTP PARAMETER DISCOVERY" "x8"
    if ! command -v x8 &> /dev/null; then
        if (
            cd /root/OK-VPS/tools &&
            wget -q https://github.com/mrco24/x8/raw/main/x8 &&
            chmod +x x8 &&
            mv -f x8 /usr/local/bin/x8
        ); then
            log_done "HTTP PARAMETER DISCOVERY" "x8"
        else
            log_fail "HTTP PARAMETER DISCOVERY" "x8" "Binary download/setup failed"
        fi
    else
        log_skip "HTTP PARAMETER DISCOVERY" "x8"
    fi
}

FUZZING_TOOLS () {
    log_start "FUZZING TOOLS" "ffuf"
    if ! command -v ffuf &> /dev/null; then
        if go install github.com/ffuf/ffuf@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/ffuf /usr/local/bin/; then
            log_done "FUZZING TOOLS" "ffuf"
        else
            log_fail "FUZZING TOOLS" "ffuf" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "FUZZING TOOLS" "ffuf"
    fi

    log_start "FUZZING TOOLS" "Gobuster"
    if ! command -v gobuster &> /dev/null; then
        if go install github.com/OJ/gobuster/v3@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/gobuster /usr/local/bin/; then
            log_done "FUZZING TOOLS" "Gobuster"
        else
            log_fail "FUZZING TOOLS" "Gobuster" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "FUZZING TOOLS" "Gobuster"
    fi

    log_start "FUZZING TOOLS" "wfuzz"
    if ! command -v wfuzz &> /dev/null; then
        if apt install -y wfuzz > /dev/null 2>&1; then
            log_done "FUZZING TOOLS" "wfuzz"
        else
            log_fail "FUZZING TOOLS" "wfuzz" "Apt install failed (Package issue)"
        fi
    else
        log_skip "FUZZING TOOLS" "wfuzz"
    fi

    log_start "FUZZING TOOLS" "dirsearch"
    if ! command -v dirsearch &> /dev/null; then
        if pip3 install git+https://github.com/maurosoria/dirsearch > /dev/null 2>&1; then
            log_done "FUZZING TOOLS" "dirsearch"
        else
            log_fail "FUZZING TOOLS" "dirsearch" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "FUZZING TOOLS" "dirsearch"
    fi

    log_start "FUZZING TOOLS" "feroxbuster"
    if ! command -v feroxbuster &> /dev/null; then
        if curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/master/install-nix.sh | bash > /dev/null 2>&1; then
            log_done "FUZZING TOOLS" "feroxbuster"
        else
            log_fail "FUZZING TOOLS" "feroxbuster" "Scripted install failed"
        fi
    else
        log_skip "FUZZING TOOLS" "feroxbuster"
    fi
}

LFI_TOOLS () {
    log_start "LFI TOOLS" "LFISuite"
    if [ ! -d "/root/OK-VPS/tools/LFISuite" ]; then
        if cd /root/OK-VPS/tools && git clone https://github.com/D35m0nd142/LFISuite.git > /dev/null 2>&1; then
            log_done "LFI TOOLS" "LFISuite"
        else
            log_fail "LFI TOOLS" "LFISuite" "Git clone failed (Network/Repository issue)"
        fi
    else
        log_skip "LFI TOOLS" "LFISuite"
    fi

    log_start "LFI TOOLS" "mrco24-lfi"
    if ! command -v mrco24-lfi &> /dev/null; then
        if go install github.com/mrco24/mrco24-lfi@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/mrco24-lfi /usr/local/bin/; then
            log_done "LFI TOOLS" "mrco24-lfi"
        else
            log_fail "LFI TOOLS" "mrco24-lfi" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "LFI TOOLS" "mrco24-lfi"
    fi
}

Open_Redirect () {
    log_start "OPEN REDIRECT" "open-redirect"
    if ! command -v open-redirect &> /dev/null; then
        if go install github.com/mrco24/open-redirect@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/open-redirect /usr/local/bin/; then
            log_done "OPEN REDIRECT" "open-redirect"
        else
            log_fail "OPEN REDIRECT" "open-redirect" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "OPEN REDIRECT" "open-redirect"
    fi
}

SSRF_TOOLS () {
    log_start "SSRF TOOLS" "SSRFmap"
    if [ ! -d "/root/OK-VPS/tools/SSRFmap" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/swisskyrepo/SSRFmap > /dev/null 2>&1 &&
            cd SSRFmap &&
            pip3 install -r requirements.txt > /dev/null 2>&1
        ); then
            log_done "SSRF TOOLS" "SSRFmap"
        else
            log_fail "SSRF TOOLS" "SSRFmap" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "SSRF TOOLS" "SSRFmap"
    fi

    log_start "SSRF TOOLS" "Gopherus"
    if [ ! -d "/root/OK-VPS/tools/Gopherus" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/tarunkant/Gopherus.git > /dev/null 2>&1 &&
            cd Gopherus &&
            chmod +x install.sh &&
            ./install.sh > /dev/null 2>&1
        ); then
            log_done "SSRF TOOLS" "Gopherus"
        else
            log_fail "SSRF TOOLS" "Gopherus" "Scripted install failed"
        fi
    else
        log_skip "SSRF TOOLS" "Gopherus"
    fi

    log_start "SSRF TOOLS" "Interactsh-client"
    if ! command -v interactsh-client &> /dev/null; then
        if GO111MODULE=on go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/interactsh-client /usr/local/bin/; then
            log_done "SSRF TOOLS" "Interactsh-client"
        else
            log_fail "SSRF TOOLS" "Interactsh-client" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "SSRF TOOLS" "Interactsh-client"
    fi
}

Http_Request_Smuggling () {
    log_start "HTTP REQUEST SMUGGLING" "http-request-smuggling"
    if [ ! -d "/root/OK-VPS/tools/http-request-smuggling" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/anshumanpattnaik/http-request-smuggling.git > /dev/null 2>&1 &&
            cd http-request-smuggling &&
            pip3 install -r requirements.txt > /dev/null 2>&1
        ); then
            log_done "HTTP REQUEST SMUGGLING" "http-request-smuggling"
        else
            log_fail "HTTP REQUEST SMUGGLING" "http-request-smuggling" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "HTTP REQUEST SMUGGLING" "http-request-smuggling"
    fi
}

SSTI_TOOLS () {
    log_start "SSTI TOOLS" "tplmap"
    if [ ! -d "/root/OK-VPS/tools/tplmap" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/epinna/tplmap.git > /dev/null 2>&1 &&
            cd tplmap &&
            pip3 install -r requirements.txt > /dev/null 2>&1 # FIXED: Using pip3
        ); then
            log_done "SSTI TOOLS" "tplmap"
        else
            log_fail "SSTI TOOLS" "tplmap" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "SSTI TOOLS" "tplmap"
    fi
}

API_TOOLS () {
    log_start "API TOOLS" "Kiterunner"
    if ! command -v kr &> /dev/null; then
        KITERUNNERVER="1.0.2" # Assuming a working version for now
        if (
            cd /root/OK-VPS/tools/file &&
            wget -q https://github.com/assetnote/kiterunner/releases/download/v"$KITERUNNERVER"/kiterunner_"$KITERUNNERVER"_linux_amd64.tar.gz &&
            tar xvf kiterunner_"$KITERUNNERVER"_linux_amd64.tar.gz > /dev/null 2>&1 &&
            mv -f kr /usr/local/bin
        ); then
            log_done "API TOOLS" "Kiterunner"
        else
            log_fail "API TOOLS" "Kiterunner" "Binary download/setup failed"
        fi

        log_start "API TOOLS" "Kiterunner Wordlists"
        if (
            cd /root/OK-VPS/tools && 
            mkdir -p kiterunner-wordlists && 
            cd kiterunner-wordlists &&
            wget -q https://wordlists-cdn.assetnote.io/data/kiterunner/routes-large.kite.tar.gz &&
            wget -q https://wordlists-cdn.assetnote.io/data/kiterunner/routes-small.kite.tar.gz &&
            for f in *.tar.gz; do tar xf "$f" && rm -Rf "$f"; done
        ); then
            log_done "API TOOLS" "Kiterunner Wordlists"
        else
            log_fail "API TOOLS" "Kiterunner Wordlists" "Wordlist download/extract failed"
        fi
    else
        log_skip "API TOOLS" "Kiterunner"
        log_skip "API TOOLS" "Kiterunner Wordlists"
    fi
}

WORDLISTS () {
    log_start "WORDLISTS" "SecLists"
    if [ ! -d "/root/wordlist/SecLists" ]; then
        if cd /root/wordlist && git clone https://github.com/danielmiessler/SecLists.git > /dev/null 2>&1; then
            log_done "WORDLISTS" "SecLists"
        else
            log_fail "WORDLISTS" "SecLists" "Git clone failed (Network/Repository issue)"
        fi
    else
        log_skip "WORDLISTS" "SecLists"
    fi

    log_start "WORDLISTS" "orwagodfather/WordList"
    if [ ! -d "/root/wordlist/WordList" ]; then
        if cd /root/wordlist && git clone https://github.com/orwagodfather/WordList.git  > /dev/null 2>&1; then
            log_done "WORDLISTS" "orwagodfather/WordList"
        else
            log_fail "WORDLISTS" "orwagodfather/WordList" "Git clone failed (Network/Repository issue)"
        fi
    else
        log_skip "WORDLISTS" "orwagodfather/WordList"
    fi

    log_start "WORDLISTS" "mrco24-wordlist"
    if [ ! -d "/root/wordlist/mrco24-wordlist" ]; then
        if cd /root/wordlist && git clone https://github.com/mrco24/mrco24-wordlist.git > /dev/null 2>&1; then
            log_done "WORDLISTS" "mrco24-wordlist"
        else
            log_fail "WORDLISTS" "mrco24-wordlist" "Git clone failed (Network/Repository issue)"
        fi
    else
        log_skip "WORDLISTS" "mrco24-wordlist"
    fi
}

VULNS_XSS () {
    log_start "VULNERABILITY - XSS" "Dalfox"
    if ! command -v dalfox &> /dev/null; then
        if GO111MODULE=on go install -v github.com/hahwul/dalfox/v2@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/dalfox /usr/local/bin/; then
            log_done "VULNERABILITY - XSS" "Dalfox"
        else
            log_fail "VULNERABILITY - XSS" "Dalfox" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "VULNERABILITY - XSS" "Dalfox"
    fi

    log_start "VULNERABILITY - XSS" "Cookieless"
    if ! command -v cookieless &> /dev/null; then
        if GO111MODULE=on go install -v github.com/RealLinkers/cookieless@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/cookieless /usr/local/bin/; then
            log_done "VULNERABILITY - XSS" "Cookieless"
        else
            log_fail "VULNERABILITY - XSS" "Cookieless" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "VULNERABILITY - XSS" "Cookieless"
    fi

    log_start "VULNERABILITY - XSS" "XSStrike"
    if [ ! -d "/root/OK-VPS/tools/XSStrike" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/s0md3v/XSStrike > /dev/null 2>&1 &&
            cd XSStrike &&
            pip3 install -r requirements.txt > /dev/null 2>&1
        ); then
            log_done "VULNERABILITY - XSS" "XSStrike"
        else
            log_fail "VULNERABILITY - XSS" "XSStrike" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "VULNERABILITY - XSS" "XSStrike"
    fi

    log_start "VULNERABILITY - XSS" "XSS_VIBES"
    if [ ! -d "/root/OK-VPS/tools/xss_vibes" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/faiyazahmad07/xss_vibes.git > /dev/null 2>&1 &&
            cd xss_vibes &&
            pip3 install -r requirements > /dev/null 2>&1
        ); then
            log_done "VULNERABILITY - XSS" "XSS_VIBES"
        else
            log_fail "VULNERABILITY - XSS" "XSS_VIBES" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "VULNERABILITY - XSS" "XSS_VIBES"
    fi

    log_start "VULNERABILITY - XSS" "kxss"
    if ! command -v kxss &> /dev/null; then
        if go install github.com/Emoe/kxss@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/kxss /usr/local/bin/; then
            log_done "VULNERABILITY - XSS" "kxss"
        else
            log_fail "VULNERABILITY - XSS" "kxss" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "VULNERABILITY - XSS" "kxss"
    fi

    log_start "VULNERABILITY - XSS" "Gxss"
    if ! command -v Gxss &> /dev/null; then
        if go install github.com/KathanP19/Gxss@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/Gxss /usr/local/bin/; then
            log_done "VULNERABILITY - XSS" "Gxss"
        else
            log_fail "VULNERABILITY - XSS" "Gxss" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "VULNERABILITY - XSS" "Gxss"
    fi

    log_start "VULNERABILITY - XSS" "findom-xss"
    if [ ! -d "/root/OK-VPS/tools/findom-xss" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/dwisiswant0/findom-xss.git > /dev/null 2>&1 &&
            cd findom-xss &&
            chmod +x findom-xss.sh &&
            rm -rf LinkFinder && # Clean up old LinkFinder just in case
            git clone https://github.com/GerbenJavado/LinkFinder.git > /dev/null 2>&1
        ); then
            log_done "VULNERABILITY - XSS" "findom-xss"
        else
            log_fail "VULNERABILITY - XSS" "findom-xss" "Git clone failed (Network/Repository issue)"
        fi
    else
        log_skip "VULNERABILITY - XSS" "findom-xss"
    fi

    log_start "VULNERABILITY - XSS" "Knoxnl"
    if ! pip show knoxnl &> /dev/null; then
        if pip install git+https://github.com/xnl-h4ck3r/knoxnl.git > /dev/null 2>&1; then
            log_done "VULNERABILITY - XSS" "Knoxnl"
        else
            log_fail "VULNERABILITY - XSS" "Knoxnl" "Pip install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "VULNERABILITY - XSS" "Knoxnl"
    fi

    log_start "VULNERABILITY - XSS" "Bxss"
    if ! command -v bxss &> /dev/null; then
        if go install -v github.com/ethicalhackingplayground/bxss/v2/cmd/bxss@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/bxss /usr/local/bin/; then
            log_done "VULNERABILITY - XSS" "Bxss"
        else
            log_fail "VULNERABILITY - XSS" "Bxss" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "VULNERABILITY - XSS" "Bxss"
    fi
}

VULNS_SQLI () {
    log_start "VULNERABILITY - SQL Injection" "SQLmap"
    if ! command -v sqlmap &> /dev/null; then
        if apt install -y sqlmap > /dev/null 2>&1; then
            log_done "VULNERABILITY - SQL Injection" "SQLmap"
        else
            log_fail "VULNERABILITY - SQL Injection" "SQLmap" "Apt install failed (Package issue)"
        fi
    else
        log_skip "VULNERABILITY - SQL Injection" "SQLmap"
    fi

    log_start "VULNERABILITY - SQL Injection" "NoSQLMap"
    if [ ! -d "/root/OK-VPS/tools/NoSQLMap" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/codingo/NoSQLMap.git > /dev/null 2>&1 &&
            cd NoSQLMap &&
            python setup.py install > /dev/null 2>&1
        ); then
            log_done "VULNERABILITY - SQL Injection" "NoSQLMap"
        else
            log_fail "VULNERABILITY - SQL Injection" "NoSQLMap" "Python setup/install failed"
        fi
    else
        log_skip "VULNERABILITY - SQL Injection" "NoSQLMap"
    fi

    log_start "VULNERABILITY - SQL Injection" "Ghauri"
    if ! command -v ghauri &> /dev/null; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/r0oth3x49/ghauri.git > /dev/null 2>&1 &&
            cd ghauri &&
            python3 -m pip install --upgrade -r requirements.txt > /dev/null 2>&1 &&
            python3 -m pip install -e . > /dev/null 2>&1
        ); then
            log_done "VULNERABILITY - SQL Injection" "Ghauri"
        else
            log_fail "VULNERABILITY - SQL Injection" "Ghauri" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "VULNERABILITY - SQL Injection" "Ghauri"
    fi

    log_start "VULNERABILITY - SQL Injection" "Jeeves"
    if ! command -v Jeeves &> /dev/null; then
        if go install github.com/ferreiraklet/Jeeves@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/Jeeves /usr/local/bin/; then
            log_done "VULNERABILITY - SQL Injection" "Jeeves"
        else
            log_fail "VULNERABILITY - SQL Injection" "Jeeves" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "VULNERABILITY - SQL Injection" "Jeeves"
    fi

    log_start "VULNERABILITY - SQL Injection" "time-sql"
    if ! command -v time-sql &> /dev/null; then
        if go install github.com/mrco24/time-sql@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/time-sql /usr/local/bin/; then
            log_done "VULNERABILITY - SQL Injection" "time-sql"
        else
            log_fail "VULNERABILITY - SQL Injection" "time-sql" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "VULNERABILITY - SQL Injection" "time-sql"
    fi

    log_start "VULNERABILITY - SQL Injection" "mrco24-error-sql"
    if ! command -v mrco24-error-sql &> /dev/null; then
        if go install github.com/mrco24/mrco24-error-sql@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/mrco24-error-sql /usr/local/bin/; then
            log_done "VULNERABILITY - SQL Injection" "mrco24-error-sql"
        else
            log_fail "VULNERABILITY - SQL Injection" "mrco24-error-sql" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "VULNERABILITY - SQL Injection" "mrco24-error-sql"
    fi
}

CMS_SCANNER () {
    log_start "CMS SCANNER" "WPScan"
    # ruby and ruby-dev now installed in CORE section
    if ! command -v wpscan &> /dev/null; then
        if (
            gem install wpscan --no-document > /dev/null 2>&1
        ); then
            log_done "CMS SCANNER" "WPScan"
        else
            log_fail "CMS SCANNER" "WPScan" "Gem install failed (Ruby dependency issue - check core install)"
        fi
    else
        log_skip "CMS SCANNER" "WPScan"
    fi

    log_start "CMS SCANNER" "Droopescan"
    if ! command -v droopescan &> /dev/null; then
        if pip3 install droopescan > /dev/null 2>&1; then
            log_done "CMS SCANNER" "Droopescan"
        else
            log_fail "CMS SCANNER" "Droopescan" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "CMS SCANNER" "Droopescan"
    fi

    log_start "CMS SCANNER" "Nrich"
    if ! command -v nrich &> /dev/null; then
        if (
            wget -q https://gitlab.com/api/v4/projects/33695681/packages/generic/nrich/latest/nrich_latest_amd64.deb &&
            DEBIAN_FRONTEND=noninteractive dpkg -i nrich_latest_amd64.deb > /dev/null 2>&1 || apt --fix-broken install -y > /dev/null 2>&1
        ); then
            log_done "CMS SCANNER" "Nrich"
        else
            log_fail "CMS SCANNER" "Nrich" "Debian package install failed"
        fi
    else
        log_skip "CMS SCANNER" "Nrich"
    fi

    log_start "CMS SCANNER" "AEM-Hacking"
    if [ ! -d "/root/OK-VPS/tools/aem-hacker" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/0ang3el/aem-hacker.git > /dev/null 2>&1 &&
            cd aem-hacker &&
            pip3 install -r requirements.txt > /dev/null 2>&1
        ); then
            log_done "CMS SCANNER" "AEM-Hacking"
        else
            log_fail "CMS SCANNER" "AEM-Hacking" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "CMS SCANNER" "AEM-Hacking"
    fi

    log_start "CMS SCANNER" "WhatWaf"
    if ! command -v whatwaf &> /dev/null; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/Ekultek/WhatWaf.git > /dev/null 2>&1 &&
            cp -f /root/OK-VPS/tools/WhatWaf/whatwaf /usr/local/bin
        ); then
            log_done "CMS SCANNER" "WhatWaf"
        else
            log_fail "CMS SCANNER" "WhatWaf" "Git clone/Binary copy failed"
        fi
    else
        log_skip "CMS SCANNER" "WhatWaf"
    fi
}

JS_HUNTING () {
    log_start "JS FILES HUNTING" "Linkfinder"
    if [ ! -d "/root/OK-VPS/tools/LinkFinder" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/GerbenJavado/LinkFinder.git > /dev/null 2>&1 &&
            cd LinkFinder &&
            pip3 install -r requirements.txt > /dev/null 2>&1 &&
            python3 setup.py install > /dev/null 2>&1
        ); then
            log_done "JS FILES HUNTING" "Linkfinder"
        else
            log_fail "JS FILES HUNTING" "Linkfinder" "Pip3 install/Python setup failed"
        fi
    else
        log_skip "JS FILES HUNTING" "Linkfinder"
    fi

    log_start "JS FILES HUNTING" "SecretFinder"
    if [ ! -d "/root/OK-VPS/tools/SecretFinder" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/m4ll0k/SecretFinder.git > /dev/null 2>&1 &&
            cd SecretFinder &&
            pip3 install -r requirements.txt jsbeautifier lxml > /dev/null 2>&1
        ); then
            log_done "JS FILES HUNTING" "SecretFinder"
        else
            log_fail "JS FILES HUNTING" "SecretFinder" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "JS FILES HUNTING" "SecretFinder"
    fi

    log_start "JS FILES HUNTING" "subjs"
    if ! command -v subjs &> /dev/null; then
        if (
            cd /root/OK-VPS/tools/file &&
            wget -q https://github.com/lc/subjs/releases/download/v1.0.1/subjs_1.0.1_linux_amd64.tar.gz &&
            tar xvf subjs_1.0.1_linux_amd64.tar.gz > /dev/null 2>&1 &&
            mv -f subjs /usr/bin/subjs
        ); then
            log_done "JS FILES HUNTING" "subjs"
        else
            log_fail "JS FILES HUNTING" "subjs" "Binary download/setup failed"
        fi
    else
        log_skip "JS FILES HUNTING" "subjs"
    fi

    log_start "JS FILES HUNTING" "Getjs"
    if ! command -v getJS &> /dev/null; then
        if go install github.com/003random/getJS/v2@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/getJS /usr/local/bin/; then
            log_done "JS FILES HUNTING" "Getjs"
        else
            log_fail "JS FILES HUNTING" "Getjs" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "JS FILES HUNTING" "Getjs"
    fi

    log_start "JS FILES HUNTING" "Jsscanner"
    if [ ! -d "/root/OK-VPS/tools/JSScanner" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/dark-warlord14/JSScanner > /dev/null 2>&1 &&
            cd JSScanner/ &&
            bash install.sh > /dev/null 2>&1
        ); then
            log_done "JS FILES HUNTING" "Jsscanner"
        else
            log_fail "JS FILES HUNTING" "Jsscanner" "Scripted install failed"
        fi
    else
        log_skip "JS FILES HUNTING" "Jsscanner"
    fi
}

GIT_HUNTING() {
    log_start "GIT HUNTING" "GitDorker"
    if [ ! -d "/root/OK-VPS/tools/GitDorker" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/obheda12/GitDorker.git > /dev/null 2>&1 &&
            cd GitDorker &&
            pip3 install -r requirements.txt > /dev/null 2>&1
        ); then
            log_done "GIT HUNTING" "GitDorker"
        else
            log_fail "GIT HUNTING" "GitDorker" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "GIT HUNTING" "GitDorker"
    fi

    log_start "GIT HUNTING" "gitGraber"
    if [ ! -d "/root/OK-VPS/tools/gitGraber" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/hisxo/gitGraber.git > /dev/null 2>&1 &&
            cd gitGraber &&
            pip3 install -r requirements.txt > /dev/null 2>&1
        ); then
            log_done "GIT HUNTING" "gitGraber"
        else
            log_fail "GIT HUNTING" "gitGraber" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "GIT HUNTING" "gitGraber"
    fi

    log_start "GIT HUNTING" "GitHacker"
    if ! command -v githacker &> /dev/null; then
        if pip3 install GitHacker > /dev/null 2>&1; then
            log_done "GIT HUNTING" "GitHacker"
        else
            log_fail "GIT HUNTING" "GitHacker" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "GIT HUNTING" "GitHacker"
    fi

    log_start "GIT HUNTING" "GitTools"
    if [ ! -d "/root/OK-VPS/tools/GitTools" ]; then
        if cd /root/OK-VPS/tools && git clone https://github.com/internetwache/GitTools.git > /dev/null 2>&1; then
            log_done "GIT HUNTING" "GitTools"
        else
            log_fail "GIT HUNTING" "GitTools" "Git clone failed (Network/Repository issue)"
        fi
    else
        log_skip "GIT HUNTING" "GitTools"
    fi
}

SENSITIVE_FINDING() {
    log_start "SENSITIVE FINDING TOOLS" "DumpsterDiver"
    if [ ! -d "/root/OK-VPS/tools/DumpsterDiver" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/securing/DumpsterDiver.git > /dev/null 2>&1 &&
            cd DumpsterDiver &&
            pip3 install -r requirements.txt > /dev/null 2>&1
        ); then
            log_done "SENSITIVE FINDING TOOLS" "DumpsterDiver"
        else
            log_fail "SENSITIVE FINDING TOOLS" "DumpsterDiver" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "SENSITIVE FINDING TOOLS" "DumpsterDiver"
    fi

    log_start "SENSITIVE FINDING TOOLS" "EarlyBird"
    if [ ! -d "/root/OK-VPS/tools/earlybird" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/americanexpress/earlybird.git > /dev/null 2>&1 &&
            cd earlybird &&
            ./build.sh > /dev/null 2>&1 &&
            ./install.sh > /dev/null 2>&1
        ); then
            log_done "SENSITIVE FINDING TOOLS" "EarlyBird"
        else
            log_fail "SENSITIVE FINDING TOOLS" "EarlyBird" "Scripted build/install failed"
        fi
    else
        log_skip "SENSITIVE FINDING TOOLS" "EarlyBird"
    fi

    log_start "SENSITIVE FINDING TOOLS" "Ripgrep"
    if ! command -v rg &> /dev/null; then
        if apt install -y ripgrep > /dev/null 2>&1; then
            log_done "SENSITIVE FINDING TOOLS" "Ripgrep"
        else
            log_fail "SENSITIVE FINDING TOOLS" "Ripgrep" "Apt install failed (Package issue)"
        fi
    else
        log_skip "SENSITIVE FINDING TOOLS" "Ripgrep"
    fi

    log_start "SENSITIVE FINDING TOOLS" "Gau-Expose"
    if [ ! -d "/root/OK-VPS/tools/Gau-Expose" ]; then
        if cd /root/OK-VPS/tools && git clone https://github.com/tamimhasan404/Gau-Expose.git > /dev/null 2>&1; then
            log_done "SENSITIVE FINDING TOOLS" "Gau-Expose"
        else
            log_fail "SENSITIVE FINDING TOOLS" "Gau-Expose" "Git clone failed (Network/Repository issue)"
        fi
    else
        log_skip "SENSITIVE FINDING TOOLS" "Gau-Expose"
    fi

    log_start "SENSITIVE FINDING TOOLS" "Mantra"
    if ! command -v mantra &> /dev/null; then
        if go install github.com/Brosck/mantra@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/mantra /usr/local/bin/; then
            log_done "SENSITIVE FINDING TOOLS" "Mantra"
        else
            log_fail "SENSITIVE FINDING TOOLS" "Mantra" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "SENSITIVE FINDING TOOLS" "Mantra"
    fi
}

Find_Web_Technologies(){
    log_start "USEFUL TOOLS" "wappalyzer-cli"
    if [ ! -d "/root/OK-VPS/tools/wappalyzer-cli" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/gokulapap/wappalyzer-cli  > /dev/null 2>&1 &&
            cd wappalyzer-cli &&
            pip3 install . > /dev/null 2>&1
        ); then
            log_done "USEFUL TOOLS" "wappalyzer-cli"
        else
            log_fail "USEFUL TOOLS" "wappalyzer-cli" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "USEFUL TOOLS" "wappalyzer-cli"
    fi
}

USEFUL_TOOLS () {
    log_start "USEFUL TOOLS" "Oralyzer"
    if [ ! -d "/root/OK-VPS/tools/Oralyzer" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/r0075h3ll/Oralyzer.git > /dev/null 2>&1 &&
            cd Oralyzer &&
            pip3 install -r requirements.txt > /dev/null 2>&1
        ); then
            log_done "USEFUL TOOLS" "Oralyzer"
        else
            log_fail "USEFUL TOOLS" "Oralyzer" "Pip3 install failed (Dependency/Compilation error)"
        fi
    else
        log_skip "USEFUL TOOLS" "Oralyzer"
    fi

    log_start "USEFUL TOOLS" "Cf-hero"
    if ! command -v cf-hero &> /dev/null; then
        if go install -v github.com/musana/cf-hero/cmd/cf-hero@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/cf-hero /usr/local/bin/; then
            log_done "USEFUL TOOLS" "Cf-hero"
        else
            log_fail "USEFUL TOOLS" "Cf-hero" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "USEFUL TOOLS" "Cf-hero"
    fi

    log_start "USEFUL TOOLS" "Notify"
    if ! command -v notify &> /dev/null; then
        if go install -v github.com/projectdiscovery/notify/cmd/notify@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/notify /usr/local/bin/; then
            log_done "USEFUL TOOLS" "Notify"
        else
            log_fail "USEFUL TOOLS" "Notify" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "USEFUL TOOLS" "Notify"
    fi

    log_start "USEFUL TOOLS" "tok"
    if ! command -v tok &> /dev/null; then
        if go install github.com/mrco24/tok@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/tok /usr/local/bin/; then
            log_done "USEFUL TOOLS" "tok"
        else
            log_fail "USEFUL TOOLS" "tok" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "USEFUL TOOLS" "tok"
    fi

    log_start "USEFUL TOOLS" "gau"
    if ! command -v gau &> /dev/null; then
        if GO111MODULE=on go install -v github.com/lc/gau@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/gau /usr/local/bin/; then
            log_done "USEFUL TOOLS" "gau"
        else
            log_fail "USEFUL TOOLS" "gau" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "USEFUL TOOLS" "gau"
    fi

    log_start "USEFUL TOOLS" "anti-burl"
    if ! command -v anti-burl &> /dev/null; then
        if go install github.com/tomnomnom/hacks/anti-burl@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/anti-burl /usr/local/bin/; then
            log_done "USEFUL TOOLS" "anti-burl"
        else
            log_fail "USEFUL TOOLS" "anti-burl" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "USEFUL TOOLS" "anti-burl"
    fi

    log_start "USEFUL TOOLS" "unfurl"
    if ! command -v unfurl &> /dev/null; then
        if go install github.com/tomnomnom/unfurl@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/unfurl /usr/local/bin/; then
            log_done "USEFUL TOOLS" "unfurl"
        else
            log_fail "USEFUL TOOLS" "unfurl" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "USEFUL TOOLS" "unfurl"
    fi

    log_start "USEFUL TOOLS" "anew"
    if ! command -v anew &> /dev/null; then
        if go install github.com/tomnomnom/anew@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/anew /usr/local/bin/; then
            log_done "USEFUL TOOLS" "anew"
        else
            log_fail "USEFUL TOOLS" "anew" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "USEFUL TOOLS" "anew"
    fi

    log_start "USEFUL TOOLS" "fff"
    if ! command -v fff &> /dev/null; then
        if go install github.com/tomnomnom/fff@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/fff /usr/local/bin/; then
            log_done "USEFUL TOOLS" "fff"
        else
            log_fail "USEFUL TOOLS" "fff" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "USEFUL TOOLS" "fff"
    fi

    log_start "USEFUL TOOLS" "subzy"
    if ! command -v subzy &> /dev/null; then
        if go install -v github.com/PentestPad/subzy@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/subzy /usr/local/bin/; then
            log_done "USEFUL TOOLS" "subzy"
        else
            log_fail "USEFUL TOOLS" "subzy" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "USEFUL TOOLS" "subzy"
    fi

    log_start "USEFUL TOOLS" "gron"
    if ! command -v gron &> /dev/null; then
        if go install github.com/tomnomnom/gron@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/gron /usr/local/bin/; then
            log_done "USEFUL TOOLS" "gron"
        else
            log_fail "USEFUL TOOLS" "gron" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "USEFUL TOOLS" "gron"
    fi

    log_start "USEFUL TOOLS" "qsreplace"
    if ! command -v qsreplace &> /dev/null; then
        if go install github.com/tomnomnom/qsreplace@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/qsreplace /usr/local/bin/; then
            log_done "USEFUL TOOLS" "qsreplace"
        else
            log_fail "USEFUL TOOLS" "qsreplace" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "USEFUL TOOLS" "qsreplace"
    fi

    log_start "USEFUL TOOLS" "Interlace"
    if [ ! -d "/root/OK-VPS/tools/Interlace" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/codingo/Interlace.git > /dev/null 2>&1 &&
            cd Interlace &&
            python3 setup.py install > /dev/null 2>&1
        ); then
            log_done "USEFUL TOOLS" "Interlace"
        else
            log_fail "USEFUL TOOLS" "Interlace" "Python setup/install failed"
        fi
    else
        log_skip "USEFUL TOOLS" "Interlace"
    fi

    log_start "USEFUL TOOLS" "jq"
    if ! command -v jq &> /dev/null; then
        if apt install -y jq > /dev/null 2>&1; then
            log_done "USEFUL TOOLS" "jq"
        else
            log_fail "USEFUL TOOLS" "jq" "Apt install failed (Package issue)"
        fi
    else
        log_skip "USEFUL TOOLS" "jq"
    fi

    log_start "USEFUL TOOLS" "cf_check"
    if ! command -v cf-check &> /dev/null; then
        if go install github.com/dwisiswant0/cf-check@latest > /dev/null 2>&1 && ln -s -f ~/go/bin/cf-check /usr/local/bin/; then
            log_done "USEFUL TOOLS" "cf_check"
        else
            log_fail "USEFUL TOOLS" "cf_check" "Go install failed (Compilation/Network error)"
        fi
    else
        log_skip "USEFUL TOOLS" "cf_check"
    fi

    log_start "USEFUL TOOLS" "Tmux"
    if ! command -v tmux &> /dev/null; then
        if apt install -y tmux > /dev/null 2>&1; then
            log_done "USEFUL TOOLS" "Tmux"
        else
            log_fail "USEFUL TOOLS" "Tmux" "Apt install failed (Package issue)"
        fi
    else
        log_skip "USEFUL TOOLS" "Tmux"
    fi

    log_start "USEFUL TOOLS" "SploitScan"
    if [ ! -d "/root/OK-VPS/tools/SploitScan" ]; then
        if cd /root/OK-VPS/tools && git clone https://github.com/xaitax/SploitScan.git > /dev/null 2>&1; then
            log_done "USEFUL TOOLS" "SploitScan"
        else
            log_fail "USEFUL TOOLS" "SploitScan" "Git clone failed (Network/Repository issue)"
        fi
    else
        log_skip "USEFUL TOOLS" "SploitScan"
    fi

    log_start "USEFUL TOOLS" "Nuclei-Clone"
    if [ ! -d "/root/OK-VPS/tools/nuclei-templates-clone" ]; then
        if (
            cd /root/OK-VPS/tools && 
            git clone https://github.com/mrco24/nuclei-templates-clone.git > /dev/null 2>&1 &&
            cd nuclei-templates-clone &&
            chmod +x c.sh &&
            /root/OK-VPS/tools/nuclei-templates-clone/./c.sh -f repo.txt > /dev/null 2>&1 &&
            /root/OK-VPS/tools/nuclei-templates-clone/./c.sh -d > /dev/null 2>&1
        ); then
            log_done "USEFUL TOOLS" "Nuclei-Clone"
        else
            log_fail "USEFUL TOOLS" "Nuclei-Clone" "Scripted clone/download failed"
        fi
    else
        log_skip "USEFUL TOOLS" "Nuclei-Clone"
    fi
}

# --- Execution Flow ---
echo -e "${YELLOW}Starting all tool installation functions...${NC}"
SUBDOMAINS_ENUMERATION
DNS_RESOLVER
VISUAL_tools
HTTP_PROBE
WEB_CRAWLING
NETWORK_SCANNER
HTTP_PARAMETER
FUZZING_TOOLS
LFI_TOOLS
Open_Redirect
SSRF_TOOLS
Http_Request_Smuggling
SSTI_TOOLS
API_TOOLS
WORDLISTS
VULNS_XSS
VULNS_SQLI
CMS_SCANNER
VULNS_SCANNER
JS_HUNTING
GIT_HUNTING
SENSITIVE_FINDING
Find_Web_Technologies
USEFUL_TOOLS

echo -e "\n${GREEN}=====================================================${NC}"
echo -e "${GREEN}ALL TOOLS INSTALLATION COMPLETE!${NC}"
echo -e "${GREEN}Run './your_script_name.sh -f' to see a list of failed tools.${NC}"
echo -e "${GREEN}Run './your_script_name.sh -h' for help and usage information.${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo -e "${YELLOW}Remember to run 'source ~/.bashrc' or restart your terminal to ensure all PATH changes are loaded.${NC}"

# Exit cleanly
exit 0
