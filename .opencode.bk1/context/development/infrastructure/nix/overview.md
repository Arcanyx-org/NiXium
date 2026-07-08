<!-- SUMMARY: Nix/NixOS development overview for NiXium. LOAD WHEN: You need general Nix development guidance. SKIP WHEN: You only need the coding standard or specific patterns. -->

# Nix/NixOS Development Overview — NiXium

This document provides an overview of Nix/NixOS development practices specific to NiXium's flake-parts infrastructure.

## Machine Configuration

In NiXium, each machine is a separate flake-parts module. The machine's `default.nix` must explicitly import its configuration files:

```nix
{ inputs, ... }: {
  flake.nixosModules.machine-name = { config, pkgs, ... }: {
    imports = [
      ./config/disks.nix
      ./config/networking.nix
      ./config/services.nix
      ./config/secrets.nix
      # Explicit imports, NOT auto-discovery
    ];
    
    # Machine-specific configuration goes here
  };
};
```

**Critical**: Files placed in `src/nixos/modules/` are NOT automatically imported. You must explicitly import them in the machine's `default.nix`.

## VM Testing

Always test Nix configuration changes in a VM before proposing to production:

```bash
# Build VM (replace <machine> with actual machine name)
nix build .#nixosConfigurations.nixos-<machine>-stable.config.system.build.vm --no-link

# Run VM with disko (recommended for machines using disko)
nix run -L '.#nixosConfigurations.nixos-<machine>-stable.config.system.build.vmWithDisko'

# Run VM without disko
nix run .#nixosConfigurations.nixos-<machine>-stable.config.system.build.vm -- -nographic
```

### VM Configuration Tips
- VMs automatically use `/dev/vda` for disk
- Set image size: `disko.devices.disk.system.imageSize = "64G";`
- Use password instead of keyFile for LUKS in VMs
- Disable swap in VM: `swapDevices = [ ];`
- Override impermanence if needed: `boot.impermanence.enable = lib.mkForce false;`

## Common Patterns

### Disko Configuration
```nix
disko.devices.disk = {
  type = "disk";
  # ... partitioning configuration
};

# For VM testing, override image size
virtualisation.vmVariantWithDisko = {
  disko.devices.disk.system.imageSize = "64G";
};
```

### Systemd Service Hardening
```nix
systemd.services.my-service = {
  serviceConfig = {
    ExecStart = pkgs.writeShellApplication {
      name = "my-service";
      bashOptions = [ "errexit" "nounset" ];
      text = ''echo "Hello World"'';
    };
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    NoNewPrivileges = true;
    PrivateUsers = true;
  };
};
```

### Secrets with Ragenix
```nix
# In secrets/my-secret.age (age-encrypted, committed to repo)
age.secrets.my-secret.file = ./secrets/my-secret.age;

# Service references the decrypted path
systemd.services.my-service = {
  environment.MY_SECRET = config.age.secrets.my-secret.path;
};
```

### Dynamic StateVersion
```nix
system.stateVersion = lib.versions.majorMinor lib.version;
# NEVER hardcode: system.stateVersion = "24.11";
```

## Related Context

- **Nix coding standard**: `../../../core/standards/nix.md` (detailed standard)
- **Project technical domain**: `../../../../project-intelligence/technical-domain.md` (NiXium's Nix stack)
- **Available models**: `../../../../core/system/available-models.md` (for agent assignment)
- **Core documentation**: `../../../core/standards/documentation.md`
- **Core code quality**: `../../../core/standards/code-quality.md`
- **AGENTS.md**: Comprehensive agent guidance for NiXium
- **QUICK_START.md**: Agent onboarding and critical architecture overview
