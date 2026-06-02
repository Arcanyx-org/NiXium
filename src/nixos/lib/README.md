# NiXium Library Functions

This directory contains reusable helper functions that are used throughout the NiXium code‑base.  All helpers follow the **Nx coding standard** and are exposed via the flake’s `lib` output.

## Available helpers

| Helper | Description |
|--------|-------------|
| `mkError` | Generates an educational error message for junior developers. |
| `mkScript` | Replacement for `pkgs.writeShellApplication` with a safe‑engine pipeline. |
| `mkVM` | Helper for building and running virtual‑machine images. |

## Using `mkError`

`mkError` is a small, pure function that returns a formatted error string.  It is intended to be used in places where a configuration error should surface as a clear, actionable message rather than a cryptic build failure.

### Importing

If you are writing a module that already receives the flake’s `lib` (most modules do), simply use:

```nix
{ lib, ... }:

let
  mkError = lib.mkError;
in
  # …use mkError
```

If you are consuming the helper from a **different flake**, add the NiXium flake as an input and reference the helper via the `lib` output:

```nix
{ inputs, ... }:

let
  mkError = inputs.nixium.lib.mkError;
in
  # …use mkError
```

### Function signature

```nix
mkError :: { what : String, why : String, how : String, docs : String? } -> String
```

| Field | Required | Description |
|-------|----------|-------------|
| `what` | ✅ | A short description of the error. |
| `why` | ✅ | Why the error matters (the safety property at risk). |
| `how` | ✅ | Concrete steps or code snippet to fix the issue. |
| `docs` | ❌ | Optional URL or reference for further reading. |

### Example usage

```nix
{ lib, ... }:

let
  mkError = lib.mkError;
in
  mkError {
    what = "derivationArgs contains protected keys";
    why  = "These keys enforce the Safe Engine pipeline (syntax check, linting, minification). Overriding them can silently disable critical validation steps.";
    how  = ''
      # WRONG – no reason supplied, default pipeline is bypassed
      mkScript {
        derivationArgs = { checkPhase = "echo 'skip checks'"; };
      }

      # RIGHT – either use hooks (additive) or provide a reason and override
      mkScript {
        name = "my-tool";
        text   = "...";
        checkPhase = "ksh -n source.sh && my‑custom‑linter source.sh";
        overrideReason = "Custom linter required for proprietary format";
      };
    '';
    docs = "src/nixos/lib/mkScript/default.nix — OVERRIDE POLICY";
  }
```

The function will return a multi‑line string that looks like:

```
###! Error: derivationArgs contains protected keys

  ###! Cause: These keys enforce the Safe Engine pipeline (syntax check, linting, minification). Overriding them can silently disable critical validation steps.

  ###! Solution:
    ###! # WRONG – no reason supplied, default pipeline is bypassed
    ###! mkScript {
    ###!   derivationArgs = { checkPhase = "echo 'skip checks'"; };
    ###! }

    ###! # RIGHT – either use hooks (additive) or provide a reason and override
    ###! mkScript {
    ###!   name = "my-tool";
    ###!   text   = "...";
    ###!   checkPhase = "ksh -n source.sh && my‑custom‑linter source.sh";
    ###!   overrideReason = "Custom linter required for proprietary format";
    ###! }

  ###! See: src/nixos/lib/mkScript/default.nix — OVERRIDE POLICY
```

### Validation

`mkError` will throw a Nix error if any of the required fields (`what`, `why`, `how`) are missing or empty.  This ensures that every call to the helper is intentional and fully documented.

---

For more information on the Nx coding standard, see the [docs/nx/standard.md](../../docs/nx/standard.md) file.
