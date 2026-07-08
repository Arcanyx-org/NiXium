<!-- SUMMARY: NiXium writeShellApplication wrapper — default to ksh, shfmt output behind optional flag. LOAD WHEN: Working on shell scripts in Nix, writeShellApplication, or POSIX compliance. SKIP WHEN: Not working on shell script tooling. -->

# Quest: NiXium writeShellApplication — ksh default, shfmt optional

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Open |
| **Priority** | Medium |
| **Created** | 2026-04-13 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |

## Problem

NiXium's current `pkgs.writeShellApplication` usage has several issues:

1. **Bash dependency is unnecessary** — NiXium's shell scripts are strict POSIX (`bashOptions = [ "posix" ]`), which means they're already ksh-compatible. Using bash as the interpreter is wasteful when ksh (which is POSIX-compliant by design) would be lighter and more correct.

2. **No formatting validation** — Shell scripts are written with `concatStringsSep "\n"` (per Nx standard), but there's no automated formatting check. shfmt would catch inconsistent indentation, spacing, and other style issues.

3. **bashOptions = [ "posix" ] is a hack** — This tells bash to run in POSIX mode, but bash's POSIX mode is incomplete and has edge cases. ksh is natively POSIX-compliant — no mode switching needed.

## Proposed Solution

Create a NiXium-specific wrapper around `pkgs.writeShellApplication` (or a replacement) that:

### 1. Default interpreter: ksh (not bash)

```nix
# Instead of:
pkgs.writeShellApplication {
  name = "my-script";
  bashOptions = [ "errexit" "nounset" "posix" ];
  runtimeInputs = [ pkgs.coreutils ];
  text = concatStringsSep "\n" [ ... ];
};

# NiXium wrapper:
niXium.writeShellApp {
  name = "my-script";
  runtimeInputs = [ pkgs.coreutils ];
  text = concatStringsSep "\n" [ ... ];
  # ksh is the default interpreter — no bashOptions needed
  # errexit and nounset are always on
  # POSIX compliance is the default, not an option
};
```

**Rationale:**
- ksh is POSIX-compliant by design — no `bashOptions = [ "posix" ]` needed
- ksh's `errexit` (`set -e`) and `nounset` (`set -u`) behave correctly
- ksh is lighter than bash (smaller closure, faster startup)
- Scripts already written for POSIX sh work in ksh without changes
- ksh93 is the reference implementation for POSIX sh

### 2. shfmt validation behind optional flag

```nix
niXium.writeShellApp {
  name = "my-script";
  runtimeInputs = [ pkgs.coreutils ];
  text = concatStringsSep "\n" [ ... ];
  format = true;  # optional, default false for now, true later
};
```

When `format = true`:
- Run `shfmt` on the script text during build
- Fail the build if formatting doesn't match the expected style
- This catches: inconsistent indentation, missing newlines, spacing issues

**Why behind a flag initially:**
- Existing scripts may not pass shfmt immediately
- Allows incremental adoption
- Eventually `format = true` becomes the default

### 3. shfmt configuration

```nix
# Proposed shfmt flags for NiXium:
# -i 0    : no indentation (tabs handled by Nix concatStringsSep)
# -ci     : indent switch cases
# -fn     : function names start on first column
# -sr     : redirect operators follow the command
```

Or use a `.editorconfig` / `shfmt` config file at the repo root.

## Implementation Plan

1. **Create `src/nixos/lib/writeShellApp/`** — the NiXium wrapper
2. **Add `pkgs.ksh` to runtimeInputs** (or use `pkgs.ksh93` / `pkgs.mirabilis`)
3. **Implement shfmt check** — use `pkgs.shfmt` in the build phase when `format = true`
4. **Migrate existing scripts** — change `bashOptions = [ "posix" ]` to the new wrapper
5. **Update Nx Language Standard** — document the new wrapper as the required way to write shell scripts
6. **Add to devShell** — `shfmt` available for local formatting

## Open Questions

- **shfmt optimization** — Run shfmt at build time when `format = true` to produce canonical script before embedding. Not for .editorconfig, but for build optimization.
- **Migration strategy?** Big-bang (all scripts at once) or incremental (new scripts use wrapper, old scripts migrate over time)?
- **runtimeEnv integration?** Currently `runtimeEnv` is a separate concern, but it could be integrated for a more ergonomic API.

## Decision (2026-04-13)

- **Which ksh?** → **ksh93 (AT&T ksh93)**
  - ksh93 is the reference implementation — full support for string replacement (`${var//pattern/replacement}`), string indexing (`${var:offset:len}`), and process substitution
  - Aligns with NiXium's `.shellcheckrc` which explicitly disables SC3060, SC3057, SC3001 to allow ksh extensions for maintainability
  - Not bash's incomplete "POSIX mode"

## Implementation Approach

### Big-Bang via ###! Comments

The library uses comprehensive `###!` comments following the mkVM pattern. If the full source is lost but the `###!` comments are preserved, any agent or human should be able to recreate the library while:
- Avoiding discovered issues (bashOptions = ["posix"] is a hack, use ksh instead)
- Following established reasoning (ksh93 as reference implementation)
- Including the full API specification in the comments

### shfmt Optimization

When `format = true`:
1. Build phase runs shfmt on the script text
2. Produces canonical formatted script
3. Embeds the optimized result

This is for build optimization, not editor integration. The .editorconfig question is separate.

### runtimeEnv and runtimeInputs

The wrapper should handle both:
- `runtimeInputs` — packages needed at build/run time (ksh93, coreutils, etc.)
- `runtimeEnv` — environment variables passed at runtime

See mkVM (lines 995-1020) for the existing pattern using both.

## Related Quests

- [posix-shell-compliance](../posix-shell-compliance/quest.md) — POSIX sh compliance for writeShellApplication
- [write-shell-application-env](../write-shell-application-env/quest.md) — runtimeEnv vs builtins.replaceStrings
- [inline-scripts-vs-standalone](../inline-scripts-vs-standalone/quest.md) — Standalone .sh files vs inline
- [add-shell-standards-to-nx-standard](../add-shell-standards-to-nx-standard/quest.md) — Comprehensive shell script standards