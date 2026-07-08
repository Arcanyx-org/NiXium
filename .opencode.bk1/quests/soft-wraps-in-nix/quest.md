<!-- SUMMARY: Comments in Nix code must use soft wraps, not hard line breaks. LOAD WHEN: Writing Nix comments, reviewing Nix code style. SKIP WHEN: Not working on Nix code formatting. -->

# Quest: Soft Wraps in Nix Code

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Open |
| **Priority** | Low |
| **Created** | 2026-04-13 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |

## Problem

Agents working on NiXium lack context that all comments in Nix code must use soft-wraps (no hard line breaks per line). Without this context, agents produce hard-wrapped comments that are difficult to maintain and reflow.

## The Anti-Pattern: Hard-Wrapped Comments

```nix
# This is a hard-wrapped comment that was manually broken
# at 80 characters. When you edit it, you have to manually
# reflow every line, which is error-prone and noisy in diffs.
```

## The Correct Pattern: Soft-Wrapped Comments

```nix
# This is a soft-wrapped comment that flows naturally and is reflowed automatically by editors or formatters. When you edit it, you only change the line you're modifying, and the rest flows naturally.
```

## Why This Matters

1. **Diff noise**: Hard wraps cause every edit to touch multiple lines, making git diffs harder to read.
2. **Maintenance burden**: Every edit requires manual reflowing of surrounding lines.
3. **Inconsistent widths**: Different contributors use different line widths, leading to jagged comments.
4. **The NiXium standard**: `docs/nx/standard.md` mandates soft wraps. The `###!` docstring format in `src/nixos/lib/vm/default.nix` uses soft wraps.

## How to Address

- Add a Nix formatter (like `nixfmt` or `alejandra`) configuration that enforces soft wraps for comments
- Add a pre-commit hook that checks for hard-wrapped comments in `.nix` files
- Add this rule to `.opencode/context/` coding standards so agents know from the start