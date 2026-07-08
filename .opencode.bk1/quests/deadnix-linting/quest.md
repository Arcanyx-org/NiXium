<!-- SUMMARY: Integrate deadnix linting into NiXium's build/validation pipeline. LOAD WHEN: Adding CI checks, fixing dead code, or setting up Nix linting. SKIP WHEN: Not working on Nix code quality or CI. -->

# Quest: Integrate deadnix into NiXium

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Open |
| **Priority** | Medium |
| **Created** | 2026-04-13 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |

## Problem

deadnix catches real issues in NiXium code that currently go undetected. Running it on `src/nixos/lib/mkVM/default.nix` found:

1. **Unused let bindings**: `optional`, `optionalString`, `elem`, `getName` — inherited from `lib`/`builtins` but never used
2. **Unused lambda patterns**: `system` parameter in `mkVmSystem` and `mkVM` — accepted but never referenced in the function body

These are dead code that should be removed. Without deadnix in the pipeline, they accumulate.

## Current Findings (mkVM)

```
line 574: Unused let binding: optionalString
line 574: Unused let binding: optional
line 575: Unused let binding: getName
line 575: Unused let binding: elem
line 760: Unused lambda pattern: system (in mkVmSystem)
line 891: Unused lambda pattern: system (in mkVM)
```

## Proposed Implementation

1. **Add deadnix to the dev shell** via `nix develop` / flake-parts
2. **Add a `, deadnix` alias** (or `, lint` alias) that runs deadnix on all `.nix` files
3. **Add a pre-commit hook** or CI check that runs `deadnix --fail` on changed files
4. **Fix all current findings** in mkVM and other files
5. **Add deadnix to the Nx Language Standard** (`docs/nx/standard.md`) as a required check

## Usage

```bash
# Check all nix files
deadnix --fail src/

# Check specific file
deadnix --fail src/nixos/lib/mkVM/default.nix

# Auto-fix (use with caution)
deadnix --fix src/nixos/lib/mkVM/default.nix
```

## Integration Points

- `docs/nx/standard.md` — add deadnix as required linting tool
- `.opencode/context/core/standards/nix.md` — add deadnix to Nix coding standard
- `flake.nix` / flake-parts — add deadnix to devShell and checks
- Pre-commit hooks or CI pipeline

## Notes

- `deadnix --fail` exits with non-zero on findings, making it CI-friendly
- `deadnix --fix` can auto-remove unused bindings, but review changes carefully
- Unused lambda patterns (like `system` in mkVM) may need `_` prefix instead of removal if the parameter position matters for readability or future use