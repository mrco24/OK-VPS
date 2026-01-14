# Bug Bounty VPS Setup Script v2.0 - Upgraded

A robust, flexible, and idempotent installation script for bug bounty and penetration testing tools. This is a complete rewrite of the original OK-VPS script with enterprise-grade features.

## 🚀 What's New in v2.0

### Major Improvements

- **✅ Flexible Installation Directory**: Install anywhere, not just `/root`
- **✅ Idempotent**: Safe to re-run, won't reinstall existing tools
- **✅ Non-Root Friendly**: Runs as regular user with selective `sudo`
- **✅ Cross-Distribution**: Ubuntu/Debian, CentOS/RHEL, Fedora/Alma, Kali
- **✅ Interactive & Non-Interactive Modes**: Choose your installation experience
- **✅ Error Handling & Logging**: Comprehensive logs and error recovery
- **✅ Smoke Testing**: Verify all tools work after installation
- **✅ Upgrade Mode**: Update existing installations
- **✅ Rollback Support**: Undo installations if needed
- **✅ CLI Compatibility Shims**: Handle upstream tool changes automatically
- **✅ PATH Management**: Automatic shell integration
- **✅ Dry-Run Mode**: Preview changes before applying

## 📋 Prerequisites

- Linux system (Ubuntu 20.04+, Debian 10+, CentOS 8+, Kali Linux, etc.)
- Bash 4.0 or higher
- Internet connection
- At least 10GB free disk space
- (Optional) sudo access for system packages

## 🔧 Quick Start

### Interactive Installation (Recommended)

```bash
git clone https://github.com/mrco24/OK-VPS.git
cd OK-VPS
chmod +x setup-bounty.sh
./setup-bounty.sh
```

The script will guide you through:
1. Choosing installation directory
2. Selecting tools to install
3. Configuring sudo usage

### Non-Interactive Installation

```bash
# Install to default location (~/.local-bounty)
./setup-bounty.sh --yes

# Install to custom location
./setup-bounty.sh --prefix /opt/bounty --yes

# Install only specific tools
./setup-bounty.sh --tools subfinder,httpx,nuclei,nmap --yes
```

### Environment Variable Configuration

```bash
# Set installation directory via environment
export INSTALL_DIR="$HOME/my-bounty-tools"
./setup-bounty.sh --yes
```

## 📚 Usage Examples

### Basic Operations

```bash
# Interactive installation
./setup-bounty.sh

# Non-interactive with defaults
./setup-bounty.sh --yes

# Custom directory
./setup-bounty.sh --prefix ~/bug-bounty-tools --yes

# Dry-run (preview without making changes)
./setup-bounty.sh --dry-run

# Upgrade existing installation
./setup-bounty.sh --upgrade --prefix ~/.local-bounty

# Dry-run upgrade to see what would change
./setup-bounty.sh --upgrade --dry-run
```

### Tool Selection

```bash
# Install specific tools only
./setup-bounty.sh --tools subfinder,httpx,nuclei,ffuf --yes

# Install by category (not yet implemented in v2.0)
# ./setup-bounty.sh --category subdomain-enumeration,fuzzing --yes
```

### Testing & Verification

```bash
# Run smoke tests after installation
./setup-bounty.sh --smoke-test

# Or use standalone script
./smoke-test.sh

# Verbose smoke tests
./smoke-test.sh --verbose

# Save results to file
./smoke-test.sh --output test-results.txt
```

### Rollback

```bash
# Remove installation
./setup-bounty.sh --rollback
```

## 📖 Command-Line Options

| Option | Description |
|--------|-------------|
| `--prefix PATH` | Installation directory (default: `~/.local-bounty`) |
| `--yes`, `-y` | Non-interactive mode, assume yes to prompts |
| `--upgrade` | Upgrade already installed tools |
| `--dry-run` | Show what would be done without changes |
| `--smoke-test` | Run verification tests |
| `--rollback` | Uninstall tools from last installation |
| `--sudo` | Use sudo for system operations |
| `--tools LIST` | Install only specified tools (comma-separated) |
| `--help`, `-h` | Show help message |
| `--version`, `-v` | Show version |

## 🛠️ Installed Tools

### Subdomain Enumeration
- [Subfinder](https://github.com/projectdiscovery/subfinder) - Fast passive subdomain enumeration
- [Assetfinder](https://github.com/tomnomnom/assetfinder) - Find domains and subdomains
- [Findomain](https://github.com/findomain/findomain) - Cross-platform subdomain enumerator
- [Amass](https://github.com/owasp-amass/amass) - In-depth DNS enumeration
- [Chaos](https://github.com/projectdiscovery/chaos-client) - Chaos dataset API client
- [github-subdomains](https://github.com/gwen001/github-subdomains) - Find subdomains on GitHub
- [Crobat](https://github.com/cgboal/sonarsearch) - Rapid7 Sonar API client

### DNS Resolver
- [dnsx](https://github.com/projectdiscovery/dnsx) - Multi-purpose DNS toolkit
- [MassDNS](https://github.com/blechschmidt/massdns) - High-performance DNS stub resolver
- [PureDNS](https://github.com/d3mondev/puredns) - Fast domain resolver
- [ShuffleDNS](https://github.com/projectdiscovery/shuffledns) - Wrapper around massdns

### HTTP Probe
- [httpx](https://github.com/projectdiscovery/httpx) - Multi-purpose HTTP toolkit
- [httprobe](https://github.com/tomnomnom/httprobe) - HTTP/HTTPS server probe

### Web Crawling
- [Katana](https://github.com/projectdiscovery/katana) - Next-gen crawling framework
- [Gospider](https://github.com/jaeles-project/gospider) - Fast web spider
- [Hakrawler](https://github.com/hakluke/hakrawler) - Quick discovery crawler
- [waybackurls](https://github.com/tomnomnom/waybackurls) - Wayback Machine URL fetcher
- [gau](https://github.com/lc/gau) - Fetch known URLs from various sources
- [gf](https://github.com/tomnomnom/gf) - Grep wrapper for patterns

### Network Scanner
- [Nmap](https://nmap.org/) - Network exploration and security scanner
- [Masscan](https://github.com/robertdavidgraham/masscan) - Fast TCP port scanner
- [Naabu](https://github.com/projectdiscovery/naabu) - Fast port scanner in Go

### Fuzzing Tools
- [ffuf](https://github.com/ffuf/ffuf) - Fast web fuzzer
- [Gobuster](https://github.com/OJ/gobuster) - Directory/DNS/VHost busting
- [Feroxbuster](https://github.com/epi052/feroxbuster) - Recursive content discovery

### Vulnerability Scanners
- [Nuclei](https://github.com/projectdiscovery/nuclei) - Fast customizable vulnerability scanner
- [SQLMap](https://github.com/sqlmapproject/sqlmap) - SQL injection tool

### XSS Tools
- [Dalfox](https://github.com/hahwul/dalfox) - Parameter analysis and XSS scanner
- [kxss](https://github.com/Emoe/kxss) - XSS vulnerability finder
- [Gxss](https://github.com/KathanP19/Gxss) - XSS tool

### Parameter Discovery
- [Arjun](https://github.com/s0md3v/Arjun) - HTTP parameter discovery
- [x8](https://github.com/Sh1Yo/x8) - Hidden parameters discovery

### Utility Tools
- [anew](https://github.com/tomnomnom/anew) - Add new lines to files
- [unfurl](https://github.com/tomnomnom/unfurl) - Pull out URL bits
- [qsreplace](https://github.com/tomnomnom/qsreplace) - Query string replacement
- [gron](https://github.com/tomnomnom/gron) - Make JSON greppable
- [jq](https://stedolan.github.io/jq/) - JSON processor
- [uro](https://github.com/s0md3v/uro) - URL declutterer
- [notify](https://github.com/projectdiscovery/notify) - Stream output to platforms

### Wordlists
- [SecLists](https://github.com/danielmiessler/SecLists) - Security assessment lists

## 📁 Directory Structure

After installation, your directory will look like:

```
~/.local-bounty/              (or your chosen directory)
├── bin/                      # Tool binaries and symlinks
├── go/                       # Go installation
├── go-packages/              # Go packages and source
├── tools/                    # Git-cloned tools
├── wordlists/                # SecLists and other wordlists
├── shims/                    # Compatibility shims
├── .installed/               # Installation stamps
│   ├── subfinder.stamp
│   ├── httpx.stamp
│   └── ...
├── install.log               # Installation log
└── manifest.lock             # Installation manifest
```

## 🔍 Idempotency

The script is fully idempotent - it's safe to run multiple times:

- **First run**: Installs all tools
- **Subsequent runs**: Skips already installed tools
- **With `--upgrade`**: Updates existing tools

Each tool has a `.stamp` file in `.installed/` tracking:
- Tool name
- Version (when available)
- Installation timestamp
- Installation directory

## 🧪 Compatibility Shims

The script includes compatibility shims for tools whose CLI has changed:

### Example: Nuclei Template Update

Old versions used: `nuclei -update-templates`
New versions use: `nuclei -ut`

The shim at `${INSTALL_DIR}/shims/nuclei` automatically translates old flags to new ones, so your existing scripts keep working.

### Creating Custom Shims

Shims are simple bash wrappers in `${INSTALL_DIR}/shims/`:

```bash
#!/bin/bash
# Example shim for 'mytool'

REAL_TOOL="${INSTALL_DIR}/bin/mytool"
args=()

for arg in "$@"; do
    case "$arg" in
        --old-flag)
            args+=("--new-flag")
            ;;
        *)
            args+=("$arg")
            ;;
    esac
done

exec "${REAL_TOOL}" "${args[@]}"
```

## 🔐 Security Considerations

- **Non-root by default**: Runs as your user, uses `sudo` only when needed
- **Package verification**: Downloads from official sources
- **No hardcoded credentials**: Original script had API keys - removed
- **Transparent operations**: Dry-run mode shows exactly what will happen
- **Audit trail**: Complete installation log

## 🐛 Troubleshooting

### Installation fails with "permission denied"

Use the `--sudo` flag:
```bash
./setup-bounty.sh --sudo --yes
```

### Tools not in PATH after installation

Reload your shell configuration:
```bash
source ~/.bashrc   # or ~/.zshrc
```

Or start a new terminal session.

### Check installation logs

```bash
cat ~/.local-bounty/install.log
```

### Verify installations

```bash
./smoke-test.sh --verbose
```

### Go installation fails

The script auto-installs Go if missing. If it fails, install manually:
```bash
sudo apt-get install golang-go   # Ubuntu/Debian
sudo dnf install golang           # Fedora/RHEL
```

### Tool X fails verification

Check if it's in PATH:
```bash
which <tool-name>
<tool-name> --version
```

## 🔄 Upgrading from v1.0 (okvps.sh)

The new script is **not** a drop-in replacement. Differences:

| Feature | v1.0 (okvps.sh) | v2.0 (setup-bounty.sh) |
|---------|-----------------|------------------------|
| Install location | Hardcoded `/root` | Configurable, default `~/.local-bounty` |
| User mode | Root only | Non-root with selective sudo |
| Idempotency | No | Yes |
| Error handling | Minimal | Comprehensive |
| Logging | No | Full logging to file |
| Testing | No | Built-in smoke tests |
| Upgrade support | No | Yes |
| OS support | Ubuntu/Debian | Multi-distro |

### Migration Steps

1. **Backup old installation** (if needed)
   ```bash
   sudo tar -czf /root/OK-VPS-backup.tar.gz /root/OK-VPS /root/wordlist /root/templates
   ```

2. **Run new installer**
   ```bash
   ./setup-bounty.sh --yes
   ```

3. **Update your scripts** to use new tool locations:
   - Old: `/usr/local/bin/subfinder`
   - New: `~/.local-bounty/bin/subfinder`

## 📊 Files Overview

- **`setup-bounty.sh`**: Main installation script
- **`smoke-test.sh`**: Standalone verification script
- **`tools.yaml`**: Tool manifest (YAML format)
- **`SETUP-README.md`**: This file
- **`okvps.sh`**: Legacy v1.0 script (preserved)

## 🤝 Contributing

Contributions welcome! To add a new tool:

1. Add entry to `tools.yaml`
2. Test installation
3. Add to smoke tests in `smoke-test.sh`
4. Update README
5. Submit PR

## 📝 License

MIT License - see original OK-VPS repository

## 🙏 Credits

- Original OK-VPS by [@mrco24](https://github.com/mrco24)
- v2.0 upgrade: Enterprise-grade rewrite with modern best practices
- All tool authors and maintainers

## 📞 Support

- **Issues**: https://github.com/mrco24/OK-VPS/issues
- **Discussions**: Use GitHub Discussions
- **Twitter**: [@mrco24](https://twitter.com/mrco24)

## 📅 Version History

- **v2.0.0** (2025): Complete rewrite with production-grade features
- **v1.0** (2023): Initial release (okvps.sh)

---

**⚠️ Disclaimer**: These tools are for authorized security testing only. Always obtain proper authorization before testing any systems you don't own.
