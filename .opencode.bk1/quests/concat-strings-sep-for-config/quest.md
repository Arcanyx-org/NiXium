<!-- SUMMARY: Use concatStringsSep instead of multiline strings for config files and script text in Nix. LOAD WHEN: Writing config file text or script text in Nix. SKIP WHEN: Not writing Nix config text. -->

# Quest: `concatStringsSep` Instead of Multiline Strings for Config Files

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Decided |
| **Priority** | High |
| **Created** | 2026-04-13 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |

## Problem

Agents working on NiXium lack context that Nix multiline strings (`''...''`) must not be used for generating configuration files or script text. Without this context, agents use `''...''` which causes tab indentation to leak into the output.

## The Anti-Pattern: Multiline Strings for Config

```nix
environment.etc."xdg/foot/foot.ini".text = ''
	[main]
	font=monospace:size=12

	[colors]
	background=1a1a1a
	foreground=dcdccc
'';
```

**Why it's wrong:** NiXium uses tabs for indentation. Nix's `''...''` multiline string strips leading whitespace up to the common indentation, but tabs and spaces are mixed inconsistently, causing tabs to leak into the generated `foot.ini` file. The result is a broken INI file with tab characters where they shouldn't be.

## The Correct Pattern: `concatStringsSep "\n"`

```nix
environment.etc."xdg/foot/foot.ini".text = concatStringsSep "\n" [
	"[main]"
	"font=monospace:size=12"
	""
	"[colors]"
	"background=1a1a1a"
	"foreground=dcdccc"
];
```

**Why it's correct:** Each line is a separate string with no indentation to strip. The `concatStringsSep "\n"` joins them with newlines. Tabs used for Nix indentation stay in the Nix code and never reach the output.

## When to Use Each

- **`concatStringsSep "\n" [...]`**: Configuration files, script text, any output where indentation must be exact.
- **`''...''`**: Acceptable only for Nix module option descriptions or documentation strings where the output is consumed by NixOS's option system (which handles its own formatting).

## How to Address

- Add this rule to `.opencode/context/` coding standards
- Consider a linter check that flags `''...''` strings assigned to `.text` attributes in `.nix` files

## Related Quests

- [add-shell-standards-to-nx-standard](../add-shell-standards-to-nx-standard/quest.md) — Comprehensive shell script standards
- [write-shell-application-env](../write-shell-application-env/quest.md) — `runtimeEnv` vs `builtins.replaceStrings`
- [soft-wraps-in-nix](../soft-wraps-in-nix/quest.md) — Soft wraps in Nix comments