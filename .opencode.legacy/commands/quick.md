# /quick - Fast Validation and Syntax Checking

**Invokes:** `quick-check` agent (Gemini 2.0 Flash Exp)

**Purpose:** Fast syntax validation, linting, and straightforward verification

## Usage

```bash
/quick <validation task>
```

## When to Use

Use `/quick` for:
- Syntax validation before committing
- Running linters (shellcheck, statix, etc.)
- Checking if files follow Nx standards
- Quick verification of correctness
- Pre-merge validation

## Examples

```bash
# Syntax checking
/quick Check syntax of src/nixos/machines/router/config/firewall.nix
/quick Does this Nix file parse correctly?

# Linting
/quick Run shellcheck on all shell scripts in services/
/quick Check for Nix anti-patterns with statix

# Standards compliance
/quick Verify tabs (not spaces) in modified files
/quick Ensure all writeShellApplication have bashOptions

# Quick validation
/quick Does the router VM build successfully?
/quick Are all imports in this file valid?
```

## Expected Output

Quick-check will return:

### ✅ PASS
```
✅ PASS: All checks successful

Details:
- Syntax valid (nix-instantiate --parse succeeded)
- Shellcheck passed (0 errors, 0 warnings)
- Uses tabs for indentation ✓
- All imports reference existing files ✓
```

### ❌ FAIL
```
❌ FAIL: Found 3 issues

src/nixos/machines/router/config/firewall.nix:
  Line 45: Syntax error - unexpected ';'
  
src/nixos/services/monitor.nix:
  Line 23: Shellcheck warning SC2086 - Double quote to prevent globbing
  Line 67: Uses spaces instead of tabs (violates Nx standard)

Suggested fixes:
  1. Remove duplicate ';' on line 45
  2. Quote variable: "$VAR" instead of $VAR
  3. Convert spaces to tabs: expand -t 4 file.nix | unexpand -t 4
```

## Performance

- **Speed:** Fast (<30 seconds typical)
- **Token usage:** Low (minimal context loaded)
- **Cost:** Free (uses Gemini free tier)

## Validation Checklist

Quick-check runs these validations:

### Nix Files
- [ ] Syntax valid (`nix-instantiate --parse`)
- [ ] Uses tabs, not spaces
- [ ] No statix warnings
- [ ] Imports reference existing files
- [ ] No hardcoded stateVersion (uses `lib.versions.majorMinor lib.version`)

### Shell Scripts
- [ ] Shellcheck passes
- [ ] Uses `writeShellApplication` (not `writeShellScriptBin`)
- [ ] Has `bashOptions` defined
- [ ] Variables quoted (`"$VAR"`)
- [ ] No `#!/bin/bash` shebang in writeShellApplication (automatic)

### General
- [ ] No plaintext secrets (basic pattern matching)
- [ ] No world-writable permissions (0666, 0777)
- [ ] No TODO/FIXME without context

## Integration Workflow

Typical workflow:
1. Make changes to Nix files
2. `/quick` to validate syntax and linting
3. Fix any issues
4. `/quick` again to confirm
5. Proceed to deeper review with `/research` or `/security`

## Quick Commands Reference

```bash
# Common quick checks
/quick syntax      # Check Nix syntax
/quick lint        # Run all linters
/quick tabs        # Verify tab usage
/quick build       # Test if VM builds
/quick shellcheck  # Check shell scripts
```

## Tips for Better Results

**Be specific about scope:**
- ✅ "Check src/nixos/machines/router/config/*.nix for syntax errors"
- ❌ "Check everything" (too broad, slow)

**One concern at a time:**
- ✅ "Run shellcheck on services/monitoring/check.nix"
- ❌ "Check syntax, linting, security, and performance" (use different agents)

**Use for pre-commit:**
```bash
# Before committing
/quick Check modified files for syntax and lint errors
```

## Known Limitations

Quick-check will **NOT**:
- Do deep security analysis (use `/security`)
- Investigate complex issues (use `/research`)
- Write new code (use `/nix`)
- Test runtime behavior (use VM testing)

If quick-check finds complex issues, it will recommend:
> "This requires deeper investigation. Try: /research <specific issue>"

## Output Format

Always includes:
- **Status:** ✅ PASS or ❌ FAIL
- **Specific errors:** With file:line references
- **Quick fixes:** If straightforward
- **Next steps:** If issue is complex

## Success Criteria

Good quick-check usage:
- ✅ Catches issues in <30 seconds
- ✅ Provides actionable error messages
- ✅ Clear pass/fail status
- ✅ Saves time (don't build VM just to find syntax error)

Poor quick-check usage:
- ❌ Used for complex debugging (use `/research`)
- ❌ Expected to find security issues (use `/security`)
- ❌ Asked to write fixes (use `/nix`)
