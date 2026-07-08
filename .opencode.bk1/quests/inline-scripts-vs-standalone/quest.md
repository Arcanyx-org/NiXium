<!-- SUMMARY: Shell scripts longer than ~20 lines must be standalone .sh files, not inline in Nix. LOAD WHEN: Writing shell scripts in Nix, deciding between inline vs standalone. SKIP WHEN: Not writing shell scripts in Nix. -->

# Quest: Inline Scripts vs Standalone Shell Files

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Decided |
| **Priority** | High |
| **Created** | 2026-04-13 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |

## Problem

Agents working on NiXium lack context that shell scripts longer than ~20 lines must not be embedded inline in Nix files. Without this context, agents produce 120+ line bash scripts inside Nix multiline strings, which are impossible to maintain, break editor syntax highlighting, and prevent `shellcheck` from linting the code.

## The Anti-Pattern: Inline Scripts

```nix
pkgs.writeShellApplication {
	name = "nixos-vm-runner";
	text = concatStringsSep "\n" [
		''HOST_ARCH="$(uname -m)"''
		''GUEST_SYSTEM="${guestSystem}"''
		''GUEST_ARCH="''${GUEST_SYSTEM%%-*}"''
		''if [ "$GUEST_ARCH" != "$HOST_ARCH" ]; then''
		''  echo "WARNING: ..." >&2''
		''fi''
		# ... 100+ more lines ...
	];
};
```

**Why it's wrong:**
1. No syntax highlighting — editors can't distinguish Nix from shell inside `''...''` strings.
2. No linting — `shellcheck` cannot analyze code embedded in Nix strings.
3. Hard to maintain — every line needs `''` escaping, making diffs noisy and error-prone.
4. No IDE support — no autocomplete, no error checking, no formatting.

## The Correct Pattern: Standalone `.sh` File

```nix
pkgs.writeShellApplication {
	name = "nixos-vm-runner";
	runtimeEnv = {
		VM_NAME = name;
		MODULE_PATH = modulePath;
		# ...
	};
	bashOptions = [ "errexit" "nounset" "pipefail" "posix" ];
	text = builtins.readFile ./runner.sh;
};
```

```sh
# runner.sh — standalone, lintable, syntax-highlighted
# shellcheck disable=SC2034
{
	: "$VM_NAME"       # Injected via runtimeEnv
	: "$MODULE_PATH"   # Injected via runtimeEnv
}

if [ -d "${FLAKE_ROOT:-}" ]; then
	export NIX_DISK_IMAGE="${MODULE_PATH}/${VM_NAME}.qcow2"
fi
# ...
```

**Why it's correct:**
1. `runner.sh` is a real shell file — editors provide full syntax highlighting and autocomplete.
2. `shellcheck` can lint it directly.
3. `builtins.readFile` includes it verbatim — no escaping needed.
4. `runtimeEnv` passes Nix values safely via environment variables.
5. The `shellcheck disable` + `: "$VAR"` pattern documents injected variables.

## Threshold

- **< 20 lines**: Inline in Nix is acceptable (simple wrappers, one-liners).
- **≥ 20 lines**: Must be a standalone `.sh` file with `builtins.readFile`.

## How to Address

- Add this rule to `.opencode/context/` coding standards
- Consider a linter check that flags `writeShellApplication` with `text` longer than 20 lines

## Related Quests

- [write-shell-application-env](../write-shell-application-env/quest.md) — `runtimeEnv` vs `builtins.replaceStrings`
- [posix-shell-compliance](../posix-shell-compliance/quest.md) — POSIX sh compliance
- [add-shell-standards-to-nx-standard](../add-shell-standards-to-nx-standard/quest.md) — Comprehensive shell script standards