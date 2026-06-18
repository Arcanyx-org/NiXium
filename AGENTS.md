# Agent Guidance for NiXium

This file provides guidance for AI agents working on NiXium. **Read this carefully** - NiXium is NOT standard NixOS, and misunderstanding this will cause you to produce broken code.

---

## Session Protocol

Every session MUST begin and end with the steps below. This exists because agents lose all memory between sessions — without this protocol, time is wasted rediscovering the same context, and mistakes are repeated.

### Before Starting Work (MUST complete)

1. Read `DISCUSSION.md` in full — it is the single most valuable source of project context.
2. Read `AGENTS.md` (this file) in full.
3. If working on a specific machine, read `src/nixos/machines/<machine>/DISCUSSION.md` if it exists.
4. Run `grep -rP "(DNM|REVIEW)((\-.*|)\(.*\)):" . --include="*.nix"` to check for open merge-blockers before touching anything.
5. Review the PR description and any open review comments.

### Before Closing Session (MUST complete)

1. **Update `DISCUSSION.md`** — add a timestamped section (format: `## <Topic> (<YYYY-MM-DD>)`) summarizing:
   - What you discovered or decided
   - Any new open issues or blockers
   - What was tested and how
   - What was NOT tested and why
2. Run shellcheck on any changed `.sh` files.
3. Run `nix-instantiate --parse` on any changed `.nix` files to catch syntax errors.
4. Tag any unresolved issues with the appropriate tag and your agent identity in parentheses.
5. If you worked on a machine config, state in the PR description whether the change was build-tested.

### DISCUSSION.md Update Rules (important for opencode.ai agents)

Many agents fail to update DISCUSSION.md. These rules make the expectation explicit:

- **ALWAYS** add an entry when you start working on a new topic, even if brief.
- **ALWAYS** add an entry when you finish work, recording what was done and what remains.
- **NEVER** skip this step because "the PR description is enough" — DISCUSSION.md persists across PRs and branches.
- Write entries in past tense describing what happened, not future plans.
- Use the section header format: `## <Topic> (<YYYY-MM-DD>)`
- If you find existing entries that are outdated, add a correction below them rather than editing them (preserves history).

---

## IMPORTANT: Keep This File Updated

This is a **living document** - you are expected to update it when you:

1. **Discover misconceptions** - If you made mistakes due to wrong assumptions, document the correct approach here
2. **Find workarounds** - If you had to figure out non-obvious solutions, add them
3. **Learn project-specific patterns** - Document patterns that work in NiXium but aren't obvious
4. **Hit obstacles** - If something doesn't work as expected, document why and what does work
5. **Find gotchas** - Any "gotchas" or common pitfalls you encounter

**When updating this file:**
- Be specific and actionable - give concrete examples
- Explain the "why" - don't just say what, explain why it works/doesn't work
- Use clear headings so other agents can find relevant sections
- If updating saves another agent from making the same mistake, do it immediately

**Example updates:**
- Adding a new "Common Issues" entry
- Correcting misunderstood architecture details
- Adding new build commands that work
- Documenting required dependencies or overlays

---

## CRITICAL: Agree Before You Implement

For any task that involves writing new files, new architecture, or non-trivial changes to existing files:

1. **Stop before touching anything.**
2. **State your proposed approach in ≤5 lines** — what you intend to do and why.
3. **Wait for explicit user approval** ("yes", "proceed", "looks good", etc.) before writing or editing any file.

This applies even if the task sounds clear. Implementation details surface misunderstandings that cost far more to undo than a 30-second approval round-trip.

**What counts as non-trivial:** new `.nix` files, new `lib/` modules, changes to `flake.nix` or machine `default.nix`, any architectural change.

**What does NOT need approval:** single-line fixes, typo corrections, adding an `import` for a file you just created at the user's direction.

---

## CRITICAL: Architecture Overview

### NiXium is a flake-parts Project, NOT Standard NixOS

This is the most important thing to understand. NiXium uses **flake-parts** for modular configuration, NOT the traditional NixOS `configuration.nix` with automatic module discovery.

**Standard NixOS (what you're probably used to):**
- Single `configuration.nix` with `imports = [ ./modules/* ]`
- Files in `modules/` are automatically available

**NiXium (this project):**
- Flake-parts modules in `src/nixos/machines/<name>/`
- Machines are defined as flake-parts modules, NOT file imports
- **You MUST explicitly import config files in the machine's `default.nix`**

### How Configuration Flows

```
flake.nix
  └── imports ./src
        └── src/nixos/default.nix (defines nixosModules.default)
              └── Each machine's default.nix is a SEPARATE flake-parts module
                    └── Machine's default.nix imports ./config/*.nix
```

**Key insight:** Adding a file to `src/nixos/modules/` does NOTHING. You must:
1. Create the config file in `src/nixos/machines/<machine>/config/`
2. Import it in `src/nixos/machines/<machine>/default.nix`

### DON'T DO THIS

- ❌ Creating files in `src/nixos/modules/` expecting automatic inclusion
- ❌ Editing `src/nixos/modules/*` and expecting machines to pick up changes
- ❌ Treating this like standard NixOS with automatic module discovery

### DO THIS INSTEAD

- ✅ Add config imports directly to machine's `default.nix`
- ✅ Create machine-specific configs in `src/nixos/machines/<machine>/config/`
- ✅ Use `src/nixos/machines/template/` as reference

---

## Where to Make Changes

| Task | Location |
|------|----------|
| Add config to a specific machine | Edit `src/nixos/machines/<machine>/default.nix`, add import |
| Create machine-specific config | Create in `src/nixos/machines/<machine>/config/` |
| Add global NixOS module | Edit `src/nixos/default.nix` to add imports |
| Add user/home-manager config | Edit files in `src/nixos/users/` |

### Using perSystem for Multi-Architecture Support

**IMPORTANT:** NiXium uses flake-parts' `perSystem` to handle multiple architectures. DO NOT use `lib.genAttrs` at the top level to create `flake.nixosConfigurations` for different systems - this breaks flake-parts' architecture handling.

**WRONG (will cause issues):**
```nix
# ❌ DON'T use genAttrs at top level for architectures
flake.nixosConfigurations = lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
    inputs.nixpkgs.lib.nixosSystem { ... }
);
```

**RIGHT (use perSystem in flake-parts):**
```nix
# ✅ DO use perSystem to handle each system automatically
perSystem = { system, pkgs, ... }: {
    packages.my-package = (inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ... ];
    }).config.system.build.isoImage;
};
```

flake-parts automatically calls `perSystem` for each configured system, so you don't need to manually create configurations for each architecture.

### Machine Directory Structure

```
src/nixos/machines/<machine>/
├── default.nix      # Main machine config (flake-parts module - THIS IS KEY)
├── config/          # Machine-specific NixOS configs (create files here)
│   ├── disks.nix
│   ├── networking.nix
│   └── ...
├── services/       # Machine-specific services
├── secrets/        # Machine-specific secrets (age)
├── releases/       # Release-specific configurations
├── lib/           # Libraries exported by machine
└── status/        # Status tracking files
```

---

## Testing Changes

**Never rely solely on LSP or syntax checking.** You MUST build and test VM configurations. The development environment includes all required tools — use them.

### Dev Environment Setup

The project uses direnv + Nix to provide a complete development environment. All tools needed to build and test are available in the devShell:

```sh
# With direnv (preferred — loads automatically on cd)
cd /path/to/NiXium
, verify    # Run verification checks

# Without direnv
nix develop
, verify
```

If Nix is available in your environment, you can and SHOULD run VM builds to verify configuration changes. The devShell provides: `nix`, `ksh`, `bashInteractive`, `shellcheck`, `nil`, `age`, `ragenix`, `sops`, `git`, and all other needed tools.

### VM Build Pattern (from appimage module)

NiXium uses a proven VM testing pattern. For any new module, follow the pattern in `src/nixos/modules/programs/appimage/default.nix`:

1. **GUI VM** — for interactive development (`virtualisation.vmVariant` with `graphics = true`)
2. **Pulse check VM** — for CI (`graphics = false`, `boot.kernelParams = [ "console=ttyS0" ]`, systemd service that runs checks and powers off)
3. **Negative test VM** — verify that failure cases actually fail

```nix
# Pulse check pattern (copy from appimage module):
let
  checkTimeout = 180;
in {
  checks.my-module-pulse = pkgs.writeShellApplication {
    name = "check-my-module-pulse";
    runtimeInputs = [ pkgs.util-linux pkgs.coreutils ];
    text = concatStringsSep "\n" [
      ''export NIX_DISK_IMAGE="/tmp/check-my-module-pulse.qcow2"''
      ''[ ! -f "$NIX_DISK_IMAGE" ] || rm "$NIX_DISK_IMAGE"''
      ''exec stdbuf -oL -eL timeout ${toString checkTimeout} "${<vmNixosSystem>.config.system.build.vm}/bin/run-nixos-vm" -nographic''
    ];
  };
}
```

The systemd service inside the VM:
```nix
systemd.services.my-module-check = {
  wantedBy = [ "multi-user.target" ];
  serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
  script = ''
    {
      # Run checks — exit 1 on failure
      my-command || exit 1
      echo "Check passed: OK"
    } > /dev/ttyS0 2>&1
    sync
    sleep 1
    systemctl poweroff
  '';
};
```

### Build and Test Commands

```sh
# Test build-vm (replace <machine> with actual machine name)
nix build .#nixosConfigurations.nixos-<machine>-stable.config.system.build.vm --no-link

# Test with disko (recommended for machines using disko)
nix run -L '.#nixosConfigurations.nixos-<machine>-stable.config.system.build.vmWithDisko'

# Run the VM after building (headless)
nix run .#nixosConfigurations.nixos-<machine>-stable.config.system.build.vm -- -nographic

# Run a module check
nix run .#checks.<system>.my-module-pulse
```

### Common VM Issues

If the build fails with "option does not exist", check nesting:
- Options go under `virtualisation.vmVariant.virtualisation` (NOT directly under `virtualisation.vmVariant`)
- Example: `virtualisation.vmVariant.virtualisation.memorySize = 2048;`

### VM Configuration Tips

- Use `virtualisation.vmVariantWithDisko` for machines with disko
- VM automatically uses /dev/vda
- Set image size: `disko.devices.disk.system.imageSize = "64G";`
- Use password instead of keyFile for LUKS
- Disable swap in VM: `swapDevices = [ ];`
- Disable impermanence in VM if needed: `boot.impermanence.enable = lib.mkForce false;`

**Always use dynamic stateVersion:**
```nix
system.stateVersion = lib.versions.majorMinor lib.version;
```
Never hardcode (e.g., NOT `"24.11"`).

---

## Coding Standards

All Nix code MUST follow the [Nx Language Standard](docs/nx/standard.md).

### Key Points

- **Indentation:** Use tabs, not spaces
- **Line length:** No hard limit, use soft wraps
- **Comments:** Explain WHY, not just WHAT
- **Secrets:** Always use age/ragenix, never hardcode

### Shell Scripts

When writing shell scripts in Nix:

1. **Always use `pkgs.writeShellApplication`** (not `pkgs.writeShellScriptBin` or `builtins.toFile`):
   ```nix
   pkgs.writeShellApplication {
     name = "my-script";
     bashOptions = [ "errexit" "nounset" ];
     runtimeInputs = [ pkgs.curl ];
     text = concatStringsSep "\n" [
       ''curl -s https://example.com''
       ''echo "Done"''
     ];
   }
   ```

2. **Use `concatStringsSep` instead of `''`:**
   ```nix
   text = concatStringsSep "\n" [
       ''for disk in ./nixos.qcow2; do''
       ''    [ ! -f "$disk" ] || rm -f "$disk"''
       ''done''
       ''exec ${vmPath} "$@"''
   ];
   ```

3. Use simplified conditionals: `[ ! -f ... ] || rm ...` instead of `if [ -f ... ]; then ...; fi`

4. Use calculations: `1024 * 5` instead of `5120`

5. **Systemd services**: Use `pkgs.writeShellApplication` for `ExecStart`:
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

6. Ensure scripts pass shellcheck

### Robust Testing Patterns

When writing automated checks that run VMs or execute tests:

1. **Prefer exit codes over output parsing** - Fragile to rely on parsing output like `grep -q "OK"`
   ```nix
   # GOOD: Rely on exit code
   text = ''
     my-command || exit 1
     systemctl poweroff
   '';
   
   # BAD: Fragile output parsing
   text = ''
     output=$(my-command)
     echo "$output" | grep -q "OK"  # FRAGILE
   '';
   ```

2. **Always use timeout wrapper** to detect hung tests:
   ```nix
   let
     checkTimeout = 180; # seconds
   in
   pkgs.writeShellApplication {
     name = "check";
     runtimeInputs = [ pkgs.util-linux ];
     text = ''
       timeout ${toString checkTimeout} ${vmPath}/bin/run-nixos-vm -nographic
     '';
   }
   ```

3. **Make timeout configurable** - Define as let variable at top of check block so it's easy to adjust.

---

## Release-Specific Configuration

NiXium supports multiple NixOS releases using attrsets as case/switch:

```nix
let
  inherit (lib) elem optionalString mkMerge;
  inherit (lib.trivial) release;
in mkMerge [
  {
    "${optionalString (elem release [ "24.05" "24.11" "25.05" ]) release}" = { /* ... */ };
    "25.11" = { /* ... */ };
  }."${release}"
]
```

This is different from `mkIf` - it does NOT evaluate the body for non-matching releases.

---

## Tagged Code

Use these tags to mark issues that need attention:

```nix
# FIXME(Krey): This should be part of nixosModules.default
```

| Tag | Meaning |
|-----|---------|
| `FIXME:` | General fixme |
| `FIXME-QA:` | Quality assurance |
| `FIXME-SECURITY:` | Security issue |
| `FIXME-UPSTREAM:` | Fix upstream |
| `TODO:` | Task for author |
| `DOCS:` | Documentation needed |
| `HACK:` | Workaround |
| `REVIEW:` | Needs review |
| `DNM:` | Do Not Merge (blocks merge) |
| `DNC:` | Do Not Contribute |
| `DNR:` | Do Not Release |
| `NOTE:` | Important note |
| `PURITY:` | Impure operation |

Search for starter issues:
```sh
grep -rP "(FIXME|TODO|DOCS|HACK|REVIEW|DNM|DNC|DNR)((\-.*|)\(.*\)):" .
```

---

## RFC 2119 Keywords

This repository uses [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119) keywords: MUST, SHOULD, MAY.

---

## Getting Started

This is a hardened codebase with strict checks. Start with small contributions fixing "tagged code" to learn the process.

**Never submit new features without issue tracking and assignment.**

```sh
# Install direnv for automatic environment loading
# Then:
cd /path/to/NiXium
, <task-name>    # direnv auto-loads (recommended)

# Examples:
, verify    # Verify system configuration
, codium    # Open in VSCodium
, tree      # Show directory structure
```

Without direnv: `nix develop` then `, <task-name>`

---

For project overview, see [README.md](README.md).
For evolving discussion context, see [DISCUSSION.md](DISCUSSION.md).
For coding standards, see [docs/nx/standard.md](docs/nx/standard.md).

---

## K1 Max 3D Printer (Creality)

This section documents findings from porting Klipper to the Creality K1 Max printer.

### Hardware Architecture

| Component | Chip | Serial | Notes |
|-----------|------|--------|-------|
| Main MCU | GD32F303RET6 | /dev/ttyS7 | Stepper motors, heaters |
| Nozzle MCU | GD32F303CBT6 | /dev/ttyS1 | Extruder, hotend fan, LED |
| Leveling MCU | GD32E230F8P6 | /dev/ttyS9 | Auto-bed-leveling sensors |

### Important Paths

| Path | Description |
|------|-------------|
| `/usr/data/klipper/` | Klipper source (symlinked from `/usr/share/klipper`) |
| `/usr/data/printer_data/config/` | Printer configuration |
| `/usr/data/printer_data/logs/` | Klipper logs |
| `/usr/share/klippy-env/` | Python virtual environment (MIPS build) |
| `/opt/etc/init.d/` | Entware services (openssh) |
| `/etc/init.d/` | System init scripts |

### Service Scripts

| Service | Init | Description |
|---------|------|-------------|
| Klipper | S55klipper_service | Main host software |
| Klipper MCU | S57klipper_mcu | MCU communication |
| Moonraker | S56moonraker_service | API server |
| Dropbear | S50dropbear | SSH (port 22) |
| OpenSSH | S45sshd (S40sshd) | SSH on port 2222 |
| Nginx | S50nginx | Web server |

### SSH Access

- **Port 2222**: OpenSSH (Entware, starts at S45)
- **Port 22**: Dropbear (default, starts at S50)
- To auto-start OpenSSH: `ln -sf /opt/etc/init.d/S40sshd /etc/init.d/S45sshd`

### Cross-Compilation for MIPS

The K1 Max uses an Ingenic X1000 MIPS processor. Klipper's C extension (`c_helper.so`) must be compiled for MIPS:

```nix
# Example cross-compile setup
pkgsCross.mips64r6-linux.pkgsStatic.gcc
# or
pkgs.buildPackages.gcc-mips-linux-gnu
```

### Known Proprietary Components

| File | Architecture | Purpose |
|------|---------------|---------|
| `prtouch_v1_wrapper.cpython-38-mipsel-linux-gnu.so` | MIPS32 | Auto-bed-leveling v1 |
| `prtouch_v2_wrapper.cpython-38-mipsel-linux-gnu.so` | MIPS32 | Auto-bed-leveling v2 |
| `prtouch_v3_wrapper.cpython-38-mipsel-linux-gnu.so` | MIPS32 | Auto-bed-leveling v3 |
| `mcu0_*.bin` | Binary | Main MCU firmware |
| `noz0_*.bin` | Binary | Nozzle MCU firmware |
| `bed0_*.bin` | Binary | Leveling MCU firmware |

Source code requested from Creality under GPL-3.0.

### K1 Max Modules (Pure Python - Usable)

These modules work without proprietary wrappers:
- `prtouch.py` - Auto bed leveling (uses hx711s)
- `bl24c16f.py` - EEPROM for power loss recovery
- `hx711s.py` - HX711 load cell sensor
- `dirzctl.py` - Z-axis stepper control
- `filter.py` - Signal filtering for probing

### Happy Hare MMU Support

MMU configuration from `~/Downloads/mmu-stuff/config/mmu/`:
- QIDI Box MMU compatible
- Pin mappings for K1 Max
- Include in printer.cfg: `[include mmu.cfg]`

### Klipper Version Detection

```bash
# Get printer model
/usr/bin/get_sn_mac.sh model   # "CR-K1 Max"
/usr/bin/get_sn_mac.sh board   # "CR4CU220812S12"
/usr/bin/get_sn_mac.sh structure_version  # "0"
```

Config directories follow pattern: `{MODEL}_{BOARD}_{VARIANT}`

### Troubleshooting

**Klipper won't start after reboot**:
1. Check `/usr/data/printer_data/logs/klippy.log`
2. Verify c_helper.so exists: `ls /usr/share/klipper/klippy/chelper/c_helper.so`
3. Check MCU connections: `ls /dev/ttyS*`

**SSH not working after reboot**:
1. Verify init link: `ls -la /etc/init.d/S45sshd`
2. Check service: `/opt/etc/init.d/S40sshd status`

**Moonraker API down**:
- Reboot via: `curl -u root:PASSWORD -X POST http://PRINTER:7125/machine/reboot`
