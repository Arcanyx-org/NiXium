<!-- SUMMARY: Why mkVM uses `let inherit` over `config._module.args` for dependency injection. LOAD WHEN: Considering injecting mkVM or other library functions into NixOS module args. SKIP WHEN: Not working on module argument injection. -->

# Quest: `let inherit` over `config._module.args` for mkVM

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Decided |
| **Priority** | Medium |
| **Created** | 2026-04-13 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |

## Problem

mkVM needs access to `lib`, `inputs`, and `self` from the flake. There are two approaches for making these available:

1. **`config._module.args`**: Inject mkVM as a module argument so it's available in all NixOS modules
2. **`let inherit`**: Bake `lib`, `inputs`, `self` into mkVM's closure at import time, then use `let inherit (self.lib) mkVM; in` at call sites

## Decision

Use `let inherit` — bake `lib`, `inputs`, `self` into the closure.

## Rationale

### `config._module.args` problems

1. **nixpkgs warns against it**: The nixpkgs module system documentation explicitly discourages `_module.args` for injecting custom values. It's designed for internal use, not as a general-purpose DI mechanism.

2. **Infinite recursion risk**: `_module.args` is evaluated early in the module system. Injecting complex values (like `self`, which references the entire flake) can trigger infinite recursion when modules try to access args that depend on the module system itself.

3. **Namespace pollution**: Every module in the system sees the injected argument, even modules that don't need it. This makes it unclear which modules depend on which values and creates coupling where none is needed.

4. **Evaluation order issues**: Module args are resolved during module system initialization. If the injected value depends on other module args or config, the evaluation order becomes unpredictable and can lead to errors that are hard to debug.

5. **Real production issues**: The NiXium maintainer experienced infinite recursion and evaluation-order bugs when using `_module.args` for library injection. These went away with `let inherit`.

### `let inherit` advantages

1. **Explicit**: The dependency is visible at the call site. `let inherit (self.lib) mkVM; in` makes it clear where mkVM comes from.

2. **No circular reference risk**: Nix is lazy. `mkVM` only accesses `self.nixosModules.default` and `self.inputs.*` when it's actually called, not at import time. The closure captures references, not evaluated values.

3. **Debuggable**: If something goes wrong, the error points to the specific `let inherit` line, not to a deeply nested module system evaluation.

4. **No namespace pollution**: Only the modules that explicitly `inherit` mkVM see it. Other modules are unaffected.

5. **Works with flake-parts**: The `flake.lib` attribute is a standard flake-parts pattern. `let inherit (self.lib) mkVM; in` is idiomatic flake-parts usage.

## Implementation

```nix
# lib/default.nix — bake closure at import
{ lib, inputs, self, ... }:
{
	flake.lib.mkVM = import ../src/nixos/lib/mkVM { inherit lib inputs self; };
}

# Call site — use let inherit
{ lib, self, inputs, ... }:
let
	inherit (self.lib) mkVM;
in mkMerge [
	{
		perSystem = { system, pkgs, ... }:
			mkVM {
				inherit pkgs system;
				name = "editors-vim-kreyren";
				# ... no need to pass inputs or self
			};
	}
]
```

## Anti-pattern

```nix
# ❌ DON'T: Inject via _module.args
{ config, ... }:
{
	config._module.args.mkVM = self.lib.mkVM;
	# Every module now sees mkVM, even unrelated ones
	# Risk of infinite recursion with self-referential args
}
```