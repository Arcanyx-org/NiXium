<!-- SUMMARY: Use runtimeEnv (not builtins.replaceStrings) to pass Nix variables into standalone shell scripts. LOAD WHEN: Writing shell scripts that need Nix values, using runtimeEnv. SKIP WHEN: Not working on shell script variable injection. -->

# Quest: `writeShellApplication` and External Shell Scripts

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Decided |
| **Priority** | High |
| **Created** | 2026-04-13 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |

## Problem

Agents working on NiXium lack context about the correct pattern for passing Nix variables into standalone shell scripts. Without this context, agents invent ad-hoc mechanisms like `builtins.replaceStrings` token substitution, which is fragile and insecure.

## The Anti-Pattern: String Replacement

When moving a script to an external file, you lose Nix's native string interpolation (e.g., `${config.name}`). A common mistake is to use `builtins.replaceStrings` to inject Nix variables into the shell script:

```nix
# WRONG ❌
text = builtins.replaceStrings [ "@name@" ] [ config.name ] (builtins.readFile ./script.sh);
```

**Why it's wrong:**
1. It breaks the external script's syntax because `@name@` is not valid shell — `shellcheck` cannot lint the file.
2. It introduces shell injection vulnerabilities if `config.name` contains spaces or special characters.
3. It reinvents a mechanism that `writeShellApplication` already provides natively.

## The Correct Pattern: `runtimeEnv`

Use the `runtimeEnv` attribute of `writeShellApplication` to safely serialize Nix variables into environment variables that the shell script reads natively.

```nix
pkgs.writeShellApplication {
	name = "my-script";
	runtimeEnv = {
		VM_NAME = config.name;
		MODULE_PATH = config.modulePath;
	};
	text = builtins.readFile ./script.sh;
}
```

In `script.sh`, reference the environment variables directly:
```sh
echo "Starting VM: $VM_NAME"
echo "Module Path: $MODULE_PATH"
```

This ensures the script remains valid POSIX shell, works with `shellcheck`, and safely handles variables with spaces or quotes.

## Critical: `runtimeEnv` Hard-Assignment Overwrites User Values

**Proven behavior:** `runtimeEnv` generates hard assignments (`VAR='value'` + `export VAR`), NOT `${VAR:-value}` defaults. This means if a user runs `MY_VAR=from-user nix run .#vm` with `runtimeEnv = { MY_VAR = "from-nix"; }`, the user's value is **overwritten**.

For variables that need runtime override (like `GPU_PASSTHROUGH`), use a `_DEFAULT` suffix:

```nix
runtimeEnv = {
	# NOT GPU_PASSTHROUGH — that would overwrite the user's runtime value
	GPU_PASSTHROUGH_DEFAULT = if gpuPassthrough == null then "" else gpuPassthrough;
};
```

```sh
# In runner.sh — runtime override wins via POSIX parameter expansion
GPU_PT="${GPU_PASSTHROUGH:-$GPU_PASSTHROUGH_DEFAULT}"
```

For variables that are pure build-time constants with no runtime override (like `VM_NAME`, `MODULE_PATH`), plain `runtimeEnv` is fine.

## Shellcheck Integration

For standalone `.sh` files included via `builtins.readFile`, `shellcheck` will not know about variables injected by `runtimeEnv`. Use the following pattern to document injected variables without disabling shellcheck globally:

```sh
# shellcheck disable=SC2034
{
	: "$VM_NAME"       # Injected via runtimeEnv — VM name for disk image
	: "$MODULE_PATH"   # Injected via runtimeEnv — path to module directory
	: "$VM_PATH"       # Injected via runtimeEnv — path to run-nixos-vm binary
}
```

`SC2034` is "variable appears unused". The `: "$VAR"` pattern is a no-op that references the variable, satisfying shellcheck while documenting its purpose.

## How to Address

- Add this pattern to `.opencode/context/` as a coding standard for shell scripts in Nix
- Consider a `shellcheck` config or pre-commit hook that recognizes `runtimeEnv` variables

## Related Quests

- [add-shell-standards-to-nx-standard](../add-shell-standards-to-nx-standard/quest.md) — Comprehensive shell script standards
- [inline-scripts-vs-standalone](../inline-scripts-vs-standalone/quest.md) — Standalone .sh files vs inline
- [posix-shell-compliance](../posix-shell-compliance/quest.md) — POSIX sh compliance