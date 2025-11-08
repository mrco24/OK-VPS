# Test Plan - Bug Bounty VPS Setup Script v2.0

## Overview

This document outlines the test plan for validating the upgraded setup-bounty.sh script.

## Test Environments

### Minimum Test Environments
1. **Ubuntu 22.04 LTS** (Primary target)
2. **Kali Linux Latest** (Bug bounty focused)
3. **Debian 11** (Stable)

### Additional Test Environments (Optional)
4. **CentOS 8 / Rocky Linux 8**
5. **Fedora Latest**
6. **Alma Linux 8**

## Test Cases

### 1. Basic Installation Tests

#### 1.1 Interactive Installation
```bash
./setup-bounty.sh
```

**Expected**:
- Shows interactive prompts
- Asks for installation directory
- Asks about sudo usage
- Asks about tool selection
- Completes successfully
- Creates all directories
- Adds to PATH in shell config

**Validation**:
- [ ] Directories created in chosen location
- [ ] Tools installed and working
- [ ] PATH updated in ~/.bashrc or ~/.zshrc
- [ ] Log file created and populated
- [ ] Manifest.lock created

#### 1.2 Non-Interactive Installation (Default Location)
```bash
./setup-bounty.sh --yes
```

**Expected**:
- Installs to ~/.local-bounty
- No prompts
- Completes without interaction
- All tools installed

**Validation**:
- [ ] ~/.local-bounty directory exists
- [ ] Minimum 10 tools installed
- [ ] install.log contains no errors
- [ ] Smoke test passes

#### 1.3 Custom Directory Installation
```bash
./setup-bounty.sh --prefix /tmp/custom-bounty --yes
```

**Expected**:
- Installs to /tmp/custom-bounty
- Creates all subdirectories there
- Tools work from custom location

**Validation**:
- [ ] /tmp/custom-bounty exists
- [ ] Tools in /tmp/custom-bounty/bin work
- [ ] No files in default location

#### 1.4 Environment Variable Configuration
```bash
export INSTALL_DIR="$HOME/my-tools"
./setup-bounty.sh --yes
```

**Expected**:
- Installs to $HOME/my-tools
- Respects environment variable

**Validation**:
- [ ] Tools in $HOME/my-tools
- [ ] manifest.lock shows correct path

### 2. Idempotency Tests

#### 2.1 Re-run Without Changes
```bash
./setup-bounty.sh --yes
./setup-bounty.sh --yes  # Run again
```

**Expected**:
- Second run much faster
- Skips already installed tools
- No re-downloads
- No errors

**Validation**:
- [ ] Second run < 30 seconds
- [ ] Log shows "already installed" messages
- [ ] Tool versions unchanged

#### 2.2 Partial Installation Recovery
```bash
# Manually delete one tool
rm ~/.local-bounty/bin/subfinder
./setup-bounty.sh --yes
```

**Expected**:
- Re-installs only the missing tool
- Leaves other tools untouched

**Validation**:
- [ ] subfinder reinstalled
- [ ] Other tools unchanged
- [ ] No duplicate work

### 3. Upgrade Tests

#### 3.1 Upgrade Mode
```bash
# Initial install
./setup-bounty.sh --yes

# Later, upgrade
./setup-bounty.sh --upgrade --yes
```

**Expected**:
- Updates Go tools (go install)
- Pulls latest git repos
- Shows what's being upgraded

**Validation**:
- [ ] Log shows upgrade activity
- [ ] Tools still work after upgrade
- [ ] Versions may change in manifest.lock

#### 3.2 Dry-Run Upgrade
```bash
./setup-bounty.sh --upgrade --dry-run
```

**Expected**:
- Shows what would be upgraded
- Makes no actual changes
- Exits successfully

**Validation**:
- [ ] No files changed
- [ ] Output shows planned actions
- [ ] Tool versions unchanged

### 4. Tool Selection Tests

#### 4.1 Specific Tools Only
```bash
./setup-bounty.sh --tools subfinder,httpx,nuclei --yes
```

**Expected**:
- Installs only 3 tools
- Skips all others
- Completes quickly

**Validation**:
- [ ] Only subfinder, httpx, nuclei installed
- [ ] Other tools not in bin/
- [ ] Dependencies (Go) still installed

### 5. Error Handling Tests

#### 5.1 No Internet Connection
```bash
# Disconnect network or use firewall
./setup-bounty.sh --yes
```

**Expected**:
- Fails gracefully
- Clear error messages
- Log shows what failed

**Validation**:
- [ ] Doesn't crash
- [ ] Error logged
- [ ] Suggests checking connection

#### 5.2 Insufficient Disk Space
```bash
# Create small filesystem
dd if=/dev/zero of=small.img bs=1M count=100
mkfs.ext4 small.img
mkdir /tmp/small
sudo mount small.img /tmp/small

./setup-bounty.sh --prefix /tmp/small --yes
```

**Expected**:
- Fails when space runs out
- Error message about disk space

**Validation**:
- [ ] Doesn't corrupt filesystem
- [ ] Clear error message
- [ ] Can rollback

#### 5.3 No Sudo Access
```bash
# As regular user without sudo
./setup-bounty.sh --yes
```

**Expected**:
- Fails on system packages
- Suggests using --sudo
- OR skips system packages

**Validation**:
- [ ] Clear message about permissions
- [ ] Doesn't corrupt system
- [ ] Logs the issue

### 6. Smoke Test Tests

#### 6.1 Smoke Test After Installation
```bash
./setup-bounty.sh --yes
./setup-bounty.sh --smoke-test
```

**Expected**:
- Tests all installed tools
- Shows pass/fail for each
- Generates report

**Validation**:
- [ ] All tests run
- [ ] Report shows results
- [ ] Exit code 0 if all pass

#### 6.2 Standalone Smoke Test
```bash
./smoke-test.sh
```

**Expected**:
- Works independently
- Tests tools in default location
- Colored output

**Validation**:
- [ ] Finds all tools
- [ ] Accurate pass/fail
- [ ] Results file created with --output

#### 6.3 Verbose Smoke Test
```bash
./smoke-test.sh --verbose
```

**Expected**:
- Shows tool version output
- More detailed feedback

**Validation**:
- [ ] Shows version strings
- [ ] Easier to debug failures

### 7. Rollback Tests

#### 7.1 Rollback Installation
```bash
./setup-bounty.sh --yes
./setup-bounty.sh --rollback
```

**Expected**:
- Asks for confirmation
- Removes installation directory
- Cleans up

**Validation**:
- [ ] Directory removed
- [ ] No leftover files
- [ ] PATH entries removed (manual check)

### 8. OS Compatibility Tests

#### 8.1 Ubuntu 22.04
```bash
# On Ubuntu 22.04
./setup-bounty.sh --yes
```

**Expected**:
- Uses apt-get
- Installs successfully
- All tools work

**Validation**:
- [ ] OS detected as ubuntu
- [ ] Package manager: apt
- [ ] Smoke tests pass

#### 8.2 Kali Linux
```bash
# On Kali Linux
./setup-bounty.sh --yes
```

**Expected**:
- Uses apt-get
- May have some tools pre-installed
- Skips pre-installed tools
- Installs missing ones

**Validation**:
- [ ] OS detected as kali
- [ ] Doesn't break existing tools
- [ ] Complements Kali tools

#### 8.3 CentOS/RHEL
```bash
# On CentOS 8 or RHEL 8
./setup-bounty.sh --yes
```

**Expected**:
- Uses dnf or yum
- Handles different package names
- Installs successfully

**Validation**:
- [ ] OS detected correctly
- [ ] Package manager: dnf or yum
- [ ] Tools work

### 9. Shim Tests

#### 9.1 Nuclei Shim
```bash
./setup-bounty.sh --yes

# Use old flag
nuclei -update-templates
```

**Expected**:
- Shim translates to -ut
- Templates update successfully
- No error about unknown flag

**Validation**:
- [ ] Templates update
- [ ] Shim intercepts correctly
- [ ] Real nuclei gets -ut flag

#### 9.2 Shim Priority in PATH
```bash
which nuclei
```

**Expected**:
- Shows shim path first
- Not real binary path

**Validation**:
- [ ] Output: ~/.local-bounty/shims/nuclei
- [ ] Not: ~/.local-bounty/bin/nuclei

### 10. Performance Tests

#### 10.1 Installation Time
```bash
time ./setup-bounty.sh --yes
```

**Expected**:
- First run: < 30 minutes
- Depends on internet speed
- Progress indicators work

**Validation**:
- [ ] Completes in reasonable time
- [ ] No indefinite hangs
- [ ] Progress visible

#### 10.2 Re-run Time (Idempotent)
```bash
time ./setup-bounty.sh --yes
# Run again
time ./setup-bounty.sh --yes
```

**Expected**:
- Second run: < 1 minute
- Much faster than first run

**Validation**:
- [ ] Second run < 60 seconds
- [ ] No re-downloads

### 11. Edge Cases

#### 11.1 Very Long Install Path
```bash
./setup-bounty.sh --prefix "$HOME/very/long/nested/directory/path/for/testing/tools" --yes
```

**Expected**:
- Handles long paths
- Creates nested directories
- Tools work

**Validation**:
- [ ] Directories created
- [ ] No path length errors
- [ ] Tools executable

#### 11.2 Special Characters in Path
```bash
./setup-bounty.sh --prefix "$HOME/test dir with spaces" --yes
```

**Expected**:
- Handles spaces in path
- Quotes paths correctly
- Tools work

**Validation**:
- [ ] Directory created
- [ ] No quoting errors
- [ ] Symlinks work

#### 11.3 Empty INSTALL_DIR
```bash
INSTALL_DIR="" ./setup-bounty.sh --yes
```

**Expected**:
- Falls back to default
- Doesn't break

**Validation**:
- [ ] Uses ~/.local-bounty
- [ ] No errors

### 12. Documentation Tests

#### 12.1 README Examples Work
Test each example from SETUP-README.md:

```bash
# Example 1
./setup-bounty.sh

# Example 2
./setup-bounty.sh --prefix ~/bug-bounty-tools --yes

# Example 3
./setup-bounty.sh --tools subfinder,httpx --yes

# etc.
```

**Validation**:
- [ ] All examples work as documented
- [ ] No errors
- [ ] Output matches expectations

#### 12.2 Help Text Accuracy
```bash
./setup-bounty.sh --help
./smoke-test.sh --help
```

**Validation**:
- [ ] All options documented
- [ ] Examples are correct
- [ ] No typos

## Success Criteria

The script is considered production-ready when:

- [ ] All "MUST PASS" tests pass on Ubuntu 22.04
- [ ] All "MUST PASS" tests pass on Kali Linux
- [ ] No critical bugs found
- [ ] Documentation matches implementation
- [ ] Smoke tests achieve >90% pass rate
- [ ] Performance within acceptable limits

## Test Execution Checklist

### Pre-Test Setup
- [ ] Clean VM or container
- [ ] Snapshot for rollback
- [ ] Internet connection verified
- [ ] Sufficient disk space (20GB+)

### During Testing
- [ ] Document all failures
- [ ] Save log files
- [ ] Screenshot errors
- [ ] Note environment details

### Post-Test
- [ ] Summarize results
- [ ] File issues for failures
- [ ] Update documentation if needed
- [ ] Mark test case pass/fail

## Known Limitations

Document any known issues that are acceptable:

1. **Requires internet**: Cannot work offline (by design)
2. **Go tools**: Some Go tools may fail if Go version too old
3. **System packages**: Some packages need sudo (documented)
4. **Disk space**: Needs ~5-10GB depending on tools selected

## Future Test Additions

Tests to add in future versions:

- [ ] CI/CD pipeline integration tests
- [ ] Multi-user installation tests
- [ ] Concurrent installation tests (multiple users)
- [ ] Network proxy tests
- [ ] Air-gapped installation (with pre-downloaded packages)
- [ ] ARM architecture tests
- [ ] macOS compatibility tests (if supported)

---

**Last Updated**: 2025-01-15
**Test Plan Version**: 1.0
**Script Version**: 2.0.0
