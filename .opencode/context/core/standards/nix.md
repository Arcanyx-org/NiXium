<!-- SUMMARY: Nix-specific coding standard for NiXium. LOAD WHEN: You are writing or reviewing Nix code. SKIP WHEN: You are working with non-Nix languages. -->

# Nix Coding Standard — NiXium

This document defines the Nix-specific coding standards for NiXium, extending the general principles with Nix-specific patterns and requirements.

## Philosophy

- **Security first**: Prefer open-source, auditable solutions
- **Declarative**: All configurations should be declarative and version-controlled
- **Use inline comments** to explain non-descriptive options
- **Use block comments** to separate code into collapsible sections in complicated files

## Code Style

### Indentation
- Use tabs for indentation (consistent with Nix tooling)
- Never use spaces for indentation

### Line Length
- Use soft wraps for long lines (concatenation or attribute sets)
- No hard 80-character limit, but use judgment for readability

### Comments
**Inline comments** - Used to explain what an option does when the option name is not descriptive enough:
```nix
security.allowSimultaneousMultithreading = mkForce true; # Disable SMT as it exposes CPU vulnerabilities
```

**Block comments** - Used to separate code into collapsible sections in complicated files:
```nix
# Kernel management
	boot.kernelPackages = pkgs.linuxPackages;

# Security
	security.allowSimultaneousMultithreading = mkForce true;
```

Use block comments sparingly - only in complicated files or to improve readability.
Avoid long comments that wrap to multiple lines - if a comment is too long, simplify it.

### Naming Conventions
- Use kebab-case for file names: `my-module.nix`
- Use camelCase for attribute names: `boot.kernelParams`
- Use descriptive names: `diskoDevice` not `d` or `disk`

## Module Structure

### Imports
Prefer flake-parts for module imports:
```nix
{ lib, config, pkgs, ... }:

{
  imports = [ ./submodule.nix ];

  options = {
    # ...
  };

  config = {
    # ...
  };
}
```

### Release-Specific Code
Use `lib.trivial.release` for conditional configuration:
```nix
let
  inherit (lib) elem optionalString;
  inherit (lib.trivial) release;
in {
  "${optionalString (elem release [ "25.05" "25.11" ]) release}" = {
    # Configuration for 25.05 and 25.11
  };
}
```

## Common Patterns

### Boolean Options
```nix
# Enable something
enable = mkEnableOption "something" // { default = true; };

# Or with explicit value
feature.enable = mkOption {
  type = types.bool;
  default = true;
  description = "Enable feature X";
};
```

### Conditional Configuration
```nix
config = mkIf config.services.foo.enable {
  # configuration
};
```

### Secrets
Always use age/ragenix for secrets:
```nix
age.secrets."service-password".file = "${self.outPath}/secrets/service-password.age";
```

### Systemd Services
Use `pkgs.writeShellApplication` for ExecStart (never `writeShellScriptBin` or `builtins.toFile`):
```nix
systemd.services.my-service = {
  serviceConfig = {
    ExecStart = pkgs.writeShellApplication {
      name = "my-service";
      bashOptions = [ "errexit" ];
      text = concatStringsSep "\n" [
        ''echo "Running"''
        ''do_something''
      ];
    };
  };
};
```

### Multi-line Strings
Use `concatStringsSep` instead of `''` for better readability and explicit line handling:
```nix
text = concatStringsSep "\n" [
  ''for disk in ./nixos.qcow2; do''
  ''  [ ! -f "$disk" ] || rm -f "$disk"''
  ''done''
  ''exec ${vmPath} "$@"''  
];
```

### StateVersion
**ALWAYS use dynamic stateVersion** - never hardcode:
```nix
system.stateVersion = lib.versions.majorMinor lib.version;
```

❌ NEVER hardcode: `system.stateVersion = "24.11";`

### Shell Scripts in Nix
When writing shell scripts in Nix:
1. **Always use `pkgs.writeShellApplication`** (not `pkgs.writeShellScriptBin` or `builtins.toFile`)
2. **Use `concatStringsSep` instead of `''`**
3. Use simplified conditionals: `[ ! -f ... ] || rm ...` instead of `if [ -f ... ]; then ...; fi`
4. Use calculations: `1024 * 5` instead of `5120`
5. Ensure scripts pass shellcheck

## Flake-Parts Specific Patterns

### Machine Configuration
Each machine's `default.nix` is a SEPARATE flake-parts module that MUST explicitly import config files:
```nix
{ inputs, ... }: {
  flake.nixosModules.machine-name = { config, pkgs, ... }: {
    imports = [
      ./config/disks.nix
      ./config/networking.nix
      ./config/services.nix
      # Explicit imports, NOT auto-discovery
    ];
    
    # Machine-specific configuration
  };
};
```

### Per-System Support
Use `perSystem` for multi-architecture support (DO NOT use `lib.genAttrs` at top level):
```nix
perSystem = { system, pkgs, ... }: {
  # Automatically called for each system (x86_64-linux, aarch64-linux, etc.)
  # No manual lib.genAttrs needed
  packages.my-package = (inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [ /* ... */ ];
  }).config.some.output;
};
```

### VM Testing Patterns
When testing in VMs:
- Use `virtualisation.vmVariantWithDisko` for machines with disko
- Set image size: `disko.devices.disk.system.imageSize = "64G";`
- Use password instead of keyFile for LUKS in VMs
- Disable swap in VM: `swapDevices = [ ];`
- Override impermanence if needed: `boot.impermanence.enable = lib.mkForce false;`

### Library Development and Git State
When adding new `lib/` modules or directories:
- **Always `git add` new files before `nix build`**. Nix copies source from the Nix store, not the working directory — untracked files are invisible to the build.
- Symptom: `error: path '/nix/store/.../lib/xxx' does not exist` during evaluation
- Fix: `git add lib/newmodule/` then rebuild
- For rapid iteration on new lib code without committing: use `nix eval --file . lib` to test evaluation directly from the working tree

## Anti-Patterns

1. **Hardcoded secrets** - Always use age/ragenix, never hardcode
2. **Using writeShellScriptBin** - Skips shellcheck validation, use writeShellApplication
3. **Hardcoding stateVersion** - Use dynamic version instead
4. **Files in src/nixos/modules/** - Not auto-discovered in flake-parts, must explicitly import
5. **Missing PURITY tag** - Tag all impure operations with `# PURITY: <reason>`
6. **Spaces instead of tabs** - Project standard uses tabs for accessibility and semantic clarity
7. **Assuming standard NixOS patterns work** - Flake-parts is different, explicit imports required
8. **Proposing code without VM testing** - Always test in VM before proposing to production
9. **Registering plain libs via `flake.lib`** - `flake.lib` is a *unique* flake-parts option; setting it from two modules raises "defined multiple times". Do not do `flake.lib.myLib = import ./myLib;` in `lib/default.nix`. Callers should `import` plain Nix library files directly.
10. **Scope bug: interpolating variables from outer scope in shell scripts** - If `${modulePath}` is only defined inside a function argument attrset, referencing it outside that scope fails at eval time. Always verify all interpolated variables are in scope with `nix eval` before editing.
11. **`^` misalignment in Nix errors means rendering, not spaces** - Nix error output points `^` at the column of the first non-whitespace character. Tabs render as 8 spaces in most terminals but Nix counts them as 1 column. The misaligned caret is a rendering artefact — NOT a reason to switch to spaces.

## Testing

- Validate Nix syntax: `nix-instantiate --parse <file.nix>`
- Check flake: `nix flake check`
- Evaluate module: `nix eval --file <file.nix> config.option`
- **ALWAYS test in VM before proposing changes to production**

## Related Context

- **Available models**: `../../system/available-models.md` (for agent assignment)
- **Project technical domain**: `../../../project-intelligence/technical-domain.md` (NiXium's Nix stack)
- **Core documentation standard**: `../../core/standards/documentation.md`
- **Core code quality**: `../../core/standards/code-quality.md`
- **Nx Language Standard**: `docs/nx/standard.md` (source document)
- **AGENTS.md**: Comprehensive agent guidance for NiXium
