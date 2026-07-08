<!-- SUMMARY: Add shell script standards (writeShellApplication, concatStringsSep, runtimeEnv, POSIX sh, standalone scripts) to the Nx Language Standard. LOAD WHEN: Writing shell scripts in Nix, updating coding standards, or reviewing shell script patterns. SKIP WHEN: Not working on shell scripts or Nx standard. -->

# Quest: Add Shell Script Standards to Nx Language Standard

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Priority** | High |
| **Created** | 2026-04-13 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |

## Problem

The Nx Language Standard (`docs/nx/standard.md`) lacks standards for shell scripts written in Nix. Agents working on NiXium have no reference for `writeShellApplication` patterns, POSIX sh compliance, or the `runtimeEnv` mechanism, leading to inconsistent and incorrect implementations.

## Missing Standards

### 1. `writeShellApplication` Mandate

Already documented in `AGENTS.md` but missing from the canonical standard. Should be in `docs/nx/standard.md`.

All shell scripts in Nix MUST use `pkgs.writeShellApplication` (never `writeShellScriptBin` or `builtins.toFile`). This provides build-time shellcheck validation.

### 2. `concatStringsSep` for Config Files

NEVER use Nix multiline strings (`''...''`) for configuration files or script text. Tab indentation leaks into the output. ALWAYS use `concatStringsSep "\n" [ ... ]`.

### 3. Standalone Shell Scripts

Scripts longer than ~20 lines MUST be stored as standalone `.sh` files and included via `builtins.readFile`. This enables proper syntax highlighting, linting, and maintainability.

### 4. `runtimeEnv` for Variable Injection

Use `runtimeEnv` (not `builtins.replaceStrings`) to pass Nix values into standalone shell scripts. `runtimeEnv` safely serializes values into environment variables.

IMPORTANT: `runtimeEnv` uses hard assignment (`VAR='value'`) which OVERWRITES any user-set environment variable of the same name. For variables that need runtime override, use a `_DEFAULT` suffix and POSIX parameter expansion: `${GPU_PASSTHROUGH:-$GPU_PASSTHROUGH_DEFAULT}`.

### 5. POSIX sh Compliance

All shell scripts MUST be strict POSIX sh (ksh compatible). Include `"posix"` in `bashOptions`. NEVER use Bash arrays, `[[ ]]`, process substitution, or other Bashisms.

### 6. Shellcheck Integration for `runtimeEnv` Variables

For standalone `.sh` files included via `builtins.readFile`, `shellcheck` will not know about variables injected by `runtimeEnv`. Use:
```sh
# shellcheck disable=SC2034 # Injected via runtimeEnv
{
	: "$VM_NAME"
	: "$MODULE_PATH"
}
```

### 7. `concatStringsSep` for Inline Scripts

For short inline scripts in `writeShellApplication`, use `concatStringsSep "\n" [ ... ]` instead of `''...''` multiline strings to prevent tab leakage.

## Proposed Addition to `docs/nx/standard.md`

Add a new section `## Shell Scripts` between `## Common Patterns` and `## Testing`:

```markdown
## Shell Scripts

### writeShellApplication

All shell scripts MUST use `pkgs.writeShellApplication` (never `writeShellScriptBin` or `builtins.toFile`):

```nix
pkgs.writeShellApplication {
	name = "my-script";
	bashOptions = [ "errexit" "nounset" "pipefail" "posix" ];
	runtimeInputs = [ pkgs.coreutils ];
	text = concatStringsSep "\n" [
		"echo 'hello'"
		"exit 0"
	];
};
```

### POSIX sh Compliance

All shell scripts MUST be strict POSIX sh (ksh compatible). Include `"posix"` in `bashOptions`. NEVER use Bash arrays (`declare -a`), `[[ ]]`, process substitution (`<()`), or other Bashisms.

### concatStringsSep for Config and Script Text

NEVER use Nix multiline strings (`''...''`) for configuration files or script text — tab indentation leaks into the output. ALWAYS use `concatStringsSep "\n" [ ... ]`:

```nix
# WRONG ❌
environment.etc."xdg/foot/foot.ini".text = ''
	[main]
	font=monospace:size=12
'';

# RIGHT ✅
environment.etc."xdg/foot/foot.ini".text = concatStringsSep "\n" [
	"[main]"
	"font=monospace:size=12"
];
```

### Standalone Shell Scripts

Scripts longer than ~20 lines MUST be stored as standalone `.sh` files and included via `builtins.readFile`:

```nix
pkgs.writeShellApplication {
	name = "my-script";
	runtimeEnv = { MY_VAR = config.myValue; };
	bashOptions = [ "errexit" "nounset" "pipefail" "posix" ];
	text = builtins.readFile ./my-script.sh;
};
```

### runtimeEnv for Variable Injection

Use `runtimeEnv` (not `builtins.replaceStrings`) to pass Nix values into shell scripts. `runtimeEnv` uses hard assignment (`VAR='value'`) which OVERWRITES user-set environment variables. For variables that need runtime override, use a `_DEFAULT` suffix:

```nix
runtimeEnv = {
	# NOT GPU_PASSTHROUGH — that would overwrite the user's runtime value
	GPU_PASSTHROUGH_DEFAULT = if cfg.gpuPassthrough == null then "" else cfg.gpuPassthrough;
};
```

```sh
# In the shell script — runtime override wins
GPU_PT="${GPU_PASSTHROUGH:-$GPU_PASSTHROUGH_DEFAULT}"
```

### Shellcheck Integration

For standalone `.sh` files, document `runtimeEnv`-injected variables with the `: "$VAR"` pattern:

```sh
# shellcheck disable=SC2034 # Injected via runtimeEnv
{
	: "$VM_NAME"
	: "$MODULE_PATH"
}
```
```

## How to Address

- Add the `## Shell Scripts` section to `docs/nx/standard.md`
- Ensure agents load this standard via ContextScout before writing shell scripts in Nix

## Related Quests

- [concat-strings-sep-for-config](../concat-strings-sep-for-config/quest.md) — Specific pattern for `concatStringsSep`
- [write-shell-application-env](../write-shell-application-env/quest.md) — `runtimeEnv` vs `builtins.replaceStrings`
- [inline-scripts-vs-standalone](../inline-scripts-vs-standalone/quest.md) — Standalone `.sh` files vs inline
- [posix-shell-compliance](../posix-shell-compliance/quest.md) — POSIX sh compliance
- [write-shell-app-ksh-shfmt](../write-shell-app-ksh-shfmt/quest.md) — ksh default, shfmt optional