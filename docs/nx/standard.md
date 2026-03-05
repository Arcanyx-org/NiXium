# Nx Language Standard

This document defines coding standards and best practices for Nix code in NiXium. The naming "Nx" distinguishes our custom programming style from standard nixpkgs-style.

## Philosophy

- Security first: Prefer open-source, auditable solutions
- Declarative: All configurations should be declarative and version-controlled
- Use inline comments to explain non-descriptive options
- Use block comments to separate code into collapsible sections

## Code Style

### Indentation

- Use tabs for indentation (consistent with Nix tooling)

### Line Length

- Use soft wraps for long lines (concatenation or attribute sets)
- No hard 80-character limit

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

**Avoid** long comments that wrap to multiple lines - if a comment is too long, simplify it.

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

## Testing

- Validate Nix syntax: `nix-instantiate --parse <file.nix>`
- Check flake: `nix flake check`
- Evaluate module: `nix eval --file <file.nix> config.option`

## Anti-Patterns

1. **Hardcoded secrets** - Always use age secrets
2. **Imperative commands** - Use declarative options
3. **Shell commands in config** - Use systemd units or NixOS options
4. **Commented-out code** - Remove or use FIXME with issue reference
5. **Using lib.* extensively** - Keep imports minimal
6. **Long wrapping comments** - Keep comments short

## References

- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
- [NixOS Options](https://nixos.org/manual/nixos/stable/options.html)
