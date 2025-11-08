# Compatibility Shims - Examples

This directory contains example compatibility shims that demonstrate how to handle CLI changes in upstream tools.

## What is a Shim?

A **shim** is a small wrapper script that sits between the user and the real tool binary. It intercepts command-line arguments, translates old flags to new ones, and then executes the real tool with the updated arguments.

This allows your existing scripts and workflows to continue working even when upstream tools change their CLI interfaces.

## How Shims Work

```
User runs:     nuclei -update-templates
                      ↓
Shim intercepts and translates to:
                      ↓
Real nuclei:   nuclei -ut
```

## Directory Structure

When installed via `setup-bounty.sh`, shims are placed in:
```
${INSTALL_DIR}/
├── bin/              # Real tool binaries
│   └── nuclei
├── shims/            # Compatibility shims (first in PATH)
│   └── nuclei        # Shim that wraps the real nuclei
```

The `shims/` directory is placed **before** `bin/` in your PATH, ensuring the shim is executed first.

## Example Shims

### 1. Nuclei Shim (`nuclei-shim.sh`)

**Problem**: Nuclei v3 changed flags:
- `-update-templates` → `-ut`
- `-update` → `-up`

**Solution**: Shim translates old flags to new ones.

**Usage**:
```bash
# Your old script still works:
nuclei -update-templates

# Shim translates it to:
nuclei -ut
```

### 2. ffuf Shim (`ffuf-shim.sh`)

A minimal example showing the shim pattern. While ffuf maintains good backward compatibility, this demonstrates how you would handle flag changes.

## Creating Your Own Shim

### Step 1: Identify the CLI Change

Find what changed in the tool:
```bash
# Example: tool changed --old-flag to --new-flag
tool --old-flag   # Used to work
tool --new-flag   # Now required
```

### Step 2: Create the Shim Script

```bash
#!/usr/bin/env bash

# Path to real tool
TOOL_REAL="${INSTALL_DIR}/bin/mytool"

if [[ -z "${INSTALL_DIR}" ]]; then
    TOOL_REAL=$(which -a mytool | grep -v "shims" | head -1)
fi

args=()

# Translate arguments
for arg in "$@"; do
    case "$arg" in
        --old-flag)
            args+=("--new-flag")
            ;;
        --another-old-flag)
            args+=("--another-new-flag")
            ;;
        *)
            # Pass through unchanged
            args+=("$arg")
            ;;
    esac
done

# Execute real tool
exec "${TOOL_REAL}" "${args[@]}"
```

### Step 3: Install the Shim

```bash
# Make it executable
chmod +x mytool-shim.sh

# Copy to shims directory
cp mytool-shim.sh ${INSTALL_DIR}/shims/mytool

# Ensure shims directory is first in PATH
export PATH="${INSTALL_DIR}/shims:${PATH}"
```

### Step 4: Test

```bash
# Test with old flag
mytool --old-flag

# Should execute real tool with new flag
```

## Advanced Shim Patterns

### Pattern 1: Conditional Translation

Only translate if the real tool doesn't support the old flag:

```bash
# Check if real tool supports old flag
if "${TOOL_REAL}" --old-flag --help &>/dev/null; then
    # Still supported, pass through
    exec "${TOOL_REAL}" "$@"
else
    # Not supported, translate
    # ... translation logic
fi
```

### Pattern 2: Value Transformation

Transform flag values, not just flag names:

```bash
for i in "${!args[@]}"; do
    arg="${args[$i]}"
    case "$arg" in
        --format)
            # Next arg is the format value
            next_arg="${args[$((i+1))]}"
            if [[ "$next_arg" == "old-format" ]]; then
                args[$((i+1))]="new-format"
            fi
            ;;
    esac
done
```

### Pattern 3: Deprecation Warnings

Warn users about deprecated flags:

```bash
for arg in "$@"; do
    case "$arg" in
        --old-flag)
            echo "Warning: --old-flag is deprecated, use --new-flag" >&2
            args+=("--new-flag")
            ;;
        *)
            args+=("$arg")
            ;;
    esac
done
```

### Pattern 4: Environment Variable Override

Allow disabling the shim via environment variable:

```bash
# Allow bypassing shim for testing
if [[ "${USE_SHIM}" == "false" ]]; then
    exec "${TOOL_REAL}" "$@"
fi

# ... rest of shim logic
```

## When to Use Shims

✅ **Good use cases:**
- Tool changed flag names but functionality is same
- You have many scripts using old flags
- Maintaining backward compatibility for a team
- Tool authors didn't provide backward compatibility

❌ **When NOT to use shims:**
- Tool's behavior fundamentally changed (not just flags)
- You're the only user and can update your scripts
- The old flags were buggy or incorrect
- Tool provides its own migration path

## Testing Shims

### Test 1: Verify Translation
```bash
# Enable bash tracing
set -x

# Run with old flag
mytool --old-flag

# Check if real tool received --new-flag
```

### Test 2: Verify Pass-Through
```bash
# Flags that shouldn't be translated should pass through
mytool --some-other-flag --unchanged-flag

# Should work exactly as before
```

### Test 3: Performance Check
```bash
# Shims add minimal overhead, but verify:
time mytool --new-flag                    # Direct call
time ${INSTALL_DIR}/shims/mytool --old-flag  # Via shim

# Should be negligible difference (< 10ms)
```

## Maintaining Shims

### Check if Shim Still Needed

Periodically test if the real tool now supports old flags:

```bash
# Try old flag with real tool
if "${INSTALL_DIR}/bin/mytool" --old-flag &>/dev/null; then
    echo "Shim may no longer be needed!"
fi
```

### Document Shims

Keep a record of why each shim exists:

```bash
# In shim header comment:
# Created: 2025-01-15
# Reason: Tool v2.0 removed --old-flag
# Can remove when: All team scripts updated (target: 2025-06-01)
```

## Troubleshooting

### Shim not being used

Check PATH order:
```bash
echo $PATH
# Should show: /path/to/shims:/path/to/bin:...

which mytool
# Should show: /path/to/shims/mytool
```

### Shim causes errors

Test the real tool directly:
```bash
# Bypass shim
${INSTALL_DIR}/bin/mytool --new-flag

# If this works, issue is in shim logic
```

### Debugging Shims

Add debug output:
```bash
# At top of shim
if [[ "${DEBUG_SHIM}" == "true" ]]; then
    echo "Shim received: $@" >&2
    echo "Translated to: ${args[@]}" >&2
fi
```

## Examples in the Wild

Real-world tools that have changed CLIs:
- **Nuclei**: `-update-templates` → `-ut`
- **SQLMap**: `--batch` behavior changes
- **ffuf**: Various flag deprecations over versions
- **Amass**: v3 → v4 major CLI changes
- **httpx**: v1 → v2 added many new flags, deprecated some old ones

## Resources

- [Shim Pattern Explanation](https://en.wikipedia.org/wiki/Shim_(computing))
- Tool-specific migration guides (check each tool's GitHub releases)
- `man bash` - Understanding argument handling in bash

## Contributing

Have a shim for a common tool? Submit a PR!

1. Add your shim to this directory
2. Name it `<tool>-shim.sh`
3. Document what CLI changes it handles
4. Add test cases

---

**Note**: Shims are a temporary compatibility measure. The best long-term solution is updating your scripts to use the new CLI flags.
