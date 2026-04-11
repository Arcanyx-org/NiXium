<!-- SUMMARY: NiXium technical context — stack, architecture, and technical decisions. LOAD WHEN: You need to understand how NiXium is built and maintained. SKIP WHEN: You only need business context or problem statement. -->

# Technical Domain — NiXium

## Core Architecture

### Flake-Parts Foundation
NiXium uses **flake-parts** for modular NixOS configuration, NOT standard NixOS `configuration.nix` with automatic module discovery.

**Key architectural flow:**
```
flake.nix
  └── src/nixos/default.nix (defines nixosModules.default)
        └── Each machine's default.nix is a SEPARATE flake-parts module
              └── Machine's default.nix explicitly imports ./config/*.nix
```

**Critical implications:**
- Files in `src/nixos/modules/` are NOT auto-discovered
- Must explicitly import config files in machine's `default.nix`
- Each machine is isolated with its own imports
- Multi-architecture support via `perSystem` (no manual `lib.genAttrs` needed)

### Machine Directory Structure
```
src/nixos/machines/<machine>/
├── default.nix      # Main machine config (flake-parts module)
├── config/          # Machine-specific NixOS configs (create files here)
│   ├── disks.nix
│   ├── networking.nix
│   ├── firewall.nix
│   └── ...
├── services/        # Machine-specific services
├── secrets/         # Machine-specific secrets (age)
├── releases/        # Release-specific configurations
├── lib/            # Libraries exported by machine
└── status/         # Status tracking files
```

## Technology Stack

### NixOS & Nix
- **NixOS releases**: Tracks multiple releases (24.05, 24.11, 25.05, 25.11) via attrset pattern
- **Dynamic stateVersion**: `system.stateVersion = lib.versions.majorMinor lib.version;` (never hardcoded)
- **Flake-parts**: Modular, explicit-import architecture
- **Disko**: Declarative disk encryption and partitioning
- **Lanzaboote**: Secure, reproducible bootloader management
- **Impermanence**: tmpfs root with explicit persistence
- **Ragenix**: Age-based secret management (replaces sops/agenix)

### Security Infrastructure
- **Zero-trust model**: All binary blobs are malware until proven otherwise
- **LUKS2 encryption**: With Argon2id key derivation (post-quantum resistant for symmetric crypto)
- **Age encryption**: For secrets (never hardcoded or plaintext)
- **Systemd hardening**: Every service gets ProtectSystem, PrivateTmp, NoNewPrivileges, etc.
- **Network segmentation**: Firewall deny-all by default, explicit allow rules
- **SSH security**: Key-only authentication, per-machine authorized_keys

### Development & Operations
- **VM testing**: Mandatory before any Nix code proposal
- **Build-time validation**: shellcheck, nvim LSP, custom security linters
- **Token-optimized agent system**: Free models for orchestration, premium for specialists
- **Context system**: Lazy-loading documentation to prevent prompt bloat
- **Head-note standard**: All .md files have `<!-- SUMMARY: ... LOAD WHEN: ... SKIP WHEN: ... -->`

## Key Technical Decisions

### 1. Flake-Parts Over Standard NixOS
**Decision**: Use flake-parts for explicit dependency management and per-machine isolation
**Why**: Avoids hidden transitive imports, enables clear machine-specific configs, supports multi-architecture via perSystem
**Trade-off**: More verbose (explicit imports required) but worth it for mission-critical clarity

### 2. Tabs Over Spaces
**Decision**: Use tabs for indentation in all Nix and code files
**Why**: Accessibility (customizable width), semantic clarity (one char = one indent level), efficiency, build-time enforcement
**Not for**: Security (this was an early misconception corrected in MEMORY.md)

### 3. writeShellApplication Mandate
**Decision**: All shell scripts must use `pkgs.writeShellApplication`, never `writeShellScriptBin` or `builtins.toFile`
**Why**: Build-time shellcheck validation prevents runtime errors, explicit dependencies, strict bash options by default
**Anti-pattern**: writeShellScriptBin skips validation, leading to CI failures

### 4. Dynamic StateVersion
**Decision**: Never hardcode `system.stateVersion`
**Why**: Release-independent design works across NixOS versions, prevents breakage when testing on different releases
**Pattern**: `system.stateVersion = lib.versions.majorMinor lib.version;`

### 5. Model Selection Strategy
**Decision**: Use diverse models optimized for specific tasks, not single model for everything
**Assignments** (verify with `opencode models <provider>`):
- **Default orchestrator**: `opencode-go/minimax-m2.7` (1M context, free)
- **Research agent**: `opencode-go/glm-5.1` (ZhiPu GLM, empirically strong for research)
- **Specialists (Nix, security, general)**: `github-copilot/claude-sonnet-4.6` (premium - use sparingly)
- **Quick check**: `opencode-go/minimax-m2.7` (same as orchestrator, free and fast)
**Why**: Better results than one-size-fits-all, avoids proprietary model bias

### 6. VM-First Testing
**Decision**: Never propose Nix code changes without VM testing first
**Why**: Build-time validation catches many issues but runtime testing is essential for mission-critical systems
**Workflow**: Build VM → Run VM → Test functionality → Test failure scenarios → Document results → Undo changes → Present proposal

## Current Machine Configurations
NiXium maintains configurations for various specialized machines (refer to `src/nixos/machines/` for current list). Common patterns include:

- **Router/firewall machines**: Heavy networking focus, custom firewall rules
- **Server machines**: Service hosting (Monero node, Vikunja, etc.)
- **Workstation machines**: Developer environments with specific toolchains
- **Edge/IoT machines**: Minimal footprint, specific hardware constraints

## Development Environment

### Required Tools
- Nix with flakes enabled
- opencode agent system (this repository)
- VM testing capability (QEMU/KVM or VirtualBox)
- Age encryption setup for secrets
- Git for version control

### Common Commands
```bash
# Test build-vm (replace <machine> with actual machine name)
nix build .#nixosConfigurations.nixos-<machine>-stable.config.system.build.vm --no-link

# Test with disko (recommended for machines using disko)
nix run -L '.#nixosConfigurations.nixos-<machine>-stable.config.system.build.vmWithDisko'

# Run the VM after building
nix run .#nixosConfigurations.nixos-<machine>-stable.config.system.build.vm -- -nographic
```

## Related Context

- **Business domain**: Why NiXium exists (mission-critical, paranoid environment)
- **Nx coding standard**: Detailed language standard (docs/nx/standard.md)
- **Agent guidance**: Comprehensive workflows (AGENTS.md)
