# Agent Guidance for NiXium

This file provides guidance for AI agents working on NiXium. **Read this carefully** - NiXium is NOT standard NixOS, and misunderstanding this will cause you to produce broken code.

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

**Never rely solely on LSP or syntax checking.** You MUST build and test VM configurations.

### Build and Test Commands

```sh
# Test build-vm (replace <machine> with actual machine name)
nix build .#nixosConfigurations.nixos-<machine>-stable.config.system.build.vm --no-link

# Test with disko (recommended for machines using disko)
nix run -L '.#nixosConfigurations.nixos-<machine>-stable.config.system.build.vmWithDisko'

# Run the VM after building
nix run .#nixosConfigurations.nixos-<machine>-stable.config.system.build.vm -- -nographic
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

### Release-Gated Option Paths (26.05+)

When NixOS/home-manager renames an option across releases, use `if` in `mkIf` conditions (not `mkIf` itself, since it evaluates both branches):

```nix
# GOOD: Only the matching branch evaluates
mkIf (if elem release [ "26.05" ]
      then config.services.desktopManager.gnome.enable
      else config.services.xserver.desktopManager.gnome.enable
) { /* ... */ }
```

Pattern for short-circuiting removed options:
```nix
# versionOlder short-circuits on 26.05+:
users.users.kreyren.extraGroups = lib.optional
  (lib.versionOlder release "26.05" && config.programs.adb.enable)
  "adbusers";
```

### Common 26.05 Deprecations

| Removed (26.05) | Replacement |
|-----------------|-------------|
| `services.xserver.desktopManager.gnome.enable` | `services.desktopManager.gnome.enable` |
| `systemd.sleep.extraConfig` | `systemd.sleep.settings.Sleep.HibernateDelaySec` |
| `programs.adb.enable` | `environment.systemPackages = [ pkgs.android-tools ]` |
| `pkgs.xorg.xkill` | `pkgs.xkill` |
| `programs.neovim.extraLuaConfig` | `programs.neovim.initLua` |
| `programs.git.userEmail` | `programs.git.settings.user.email` |
| `programs.vscode` package field | use `programs.vscodium` on 26.05+ |
| Scripted initrd (`boot.initrd.systemd.enable = false`) | must use systemd initrd |
| `pkgs.firefox` binary name (25.11→26.05) | `firefox` (not `firefox-esr`) — 25.11 shipped ESR as default |

### NixOS 26.05 GNOME Notes (GNOME 49/50)

- **NixOS 25.11**: GNOME 46, **NixOS 26.05**: GNOME 49/50 (NOT GNOME 48 as assumed)
- `custom-accent-colors@demiskp` extension only supports up to GNOME 46 — already gated to ≤24.05 in NiXium; on 26.05 native accent-color is used
- Caffeine extension v57 breaks on GNOME 49 (OSD API change); v58+ works — verify packaged version
- gnome-shell-extensions (drive-menu, user-theme) not auto-installed since 25.05 — explicit packages are fine

### Impermanence Fork fsType Fix

The kreyren impermanence fork (`github:kreyren/impermanence`, rev `5f94a1c`) does NOT set `fsType` in `mkBindMountNameValuePair`. NixOS 26.05+ requires `fsType` (`types.nonEmptyStr`, no default).

**Real solution** (not workaround): Patch both `fileSystems` AND `virtualisation.fileSystems` to add `fsType`. The fork already sets `virtualisation.fileSystems = bindMounts` — qemu-vm.nix reads from this when creating VM variant entries.

```nix
fileSystems = dirsToFsType allDirs;
virtualisation.fileSystems = dirsToFsType allDirs;  # qemu-vm.nix mirrors this
```

Do NOT use `virtualisation.vmVariant.fileSystems` or `virtualisation.vmVariant.virtualisation.fileSystems` — these are fragile workarounds. Fix the source (`virtualisation.fileSystems`) that qemu-vm.nix copies from.

**Do not** use `mkOverride 140` on fileSystems (replaces entire attrset, losing root fs). Use `mkDefault "none"` on individual entries — NixOS merges submodule attrs correctly.

### Vendored HM `stripHomePrefix` Feature

The vendored impermanence at `vendor/impermanence/` has a custom `stripHomePrefix` option (upstream has none).

**What it does:** When set to `true` on a `home.persistence."<path>"` store, it strips the home directory prefix from the persistent storage path. Without it, `Desktop` is stored at `<persistentStoragePath>/home/kreyren/Desktop`; with it, at `<persistentStoragePath>/Desktop`.

**Implementation:**
- `submodule-options.nix`: Declared at store level (in `!usersOpts` block) with `default = false`, and at dir/file level in `commonOpts` inheriting from store via `default = config.stripHomePrefix`. A new internal `sourcePath` option carries the path without home prefix.
- `nixos.nix`: All `what` (source) paths in systemd mount units, initrd mounts, and create-directories scripts use `sourcePath ?? dirPath` (defaulting to `dirPath` for backward compat). The `mkParent` function checks `stripHomePrefix` to determine whether to prepend `dir.home`.
- Both `sourcePath` option declarations use `type = str` (not `path`) because it can be relative when `stripHomePrefix = true`.

**Usage:**
```nix
home.persistence."/nix/persist/users/kreyren" = {
  stripHomePrefix = true;
  directories = [ "Desktop" "Documents" ];
};
```

### Release-Gating Pattern for VSCode/VSCodium

Use `if ... else if` chain in module definitions to pick the right option per release:
```nix
{ config, lib, pkgs, ... }:
let
  inherit (lib) elem mkIf mkMerge;
  inherit (lib.trivial) release;
in
if elem release [ "24.11" ] then {
  # uses programs.vscode with extensions
} else if elem release [ "25.05" "25.11" ] then {
  # uses programs.vscode with profiles
} else {
  # 26.05+: uses programs.vscodium directly
}
```

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

## Persistence Mount Failures — Root Cause & Fix

**Root cause:** `systemd.mount` units for impermanence bind mounts fail at boot when the source path (in persistent storage) doesn't exist yet. The vendored impermanence module creates these dirs in an activation script (`create-directories.bash`), but activation scripts run after `local-fs.target` — so the mount unit fails before the dir is created.

**Fix in `src/nixos/modules/system/impermenance/system-impermenance.nix`:**
Generate `systemd.tmpfiles.rules` entries (`d` type) for ALL persistence source paths — both system stores (`environment.persistence`) and HM user stores (`home-manager.users.*.home.persistence`). tmpfiles runs before `local-fs.target`, ensuring source paths exist when mount units attempt to bind.

**Key implementation details:**
- `mkDirRule` — creates `d` entry for each directory's `sourcePath` (the persistent storage path)
- `mkFileParentRule` — creates `d` entry for each file's parent dir (file persistence creates a symlink, not a directory)
- System user sub-stores (`users.<name>` under system persistence) inherit the parent store's `persistentStoragePath` since they don't have their own top-level option
- Use `nullToDash` helper to convert `null` user/group/mode to `-` (tmpfiles' "no change" sentinel) — important for HM stores where `group = null` by default
- `lib.flatten` is from `lib`, not `builtins`; `hasPrefix` is from `lib`, not `builtins`

**Verification:** Check `/nix/store/*tmpfiles.d*/lib/tmpfiles.d/00-nixos.conf` for entries like:
```
d /nix/persist/system/var/log 0755 root root -
d /nix/persist/users/kreyren/.ssh 0755 kreyren - -
```

**Avoid:** Don't rely on activation scripts to create persistence dirs — they run too late. Don't use `mkOverride` on fileSystems or virtualisation.fileSystems to fix this (fragile).

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

---

## SSH Host Key Deployment in VMs

**Problem:** Machine config (`openssh.nix`) sets `hostKeys = mkForce []` and `sshd-keygen.enable = mkForce false` because SSH host keys come from age secrets on real hardware. In VMs, age secrets are unavailable (no identity), so keys must be generated differently.

**What does NOT work:**
1. **Activation scripts** — files created in initrd are lost after `switch_root`
2. **systemd.tmpfiles `C` rules** — subject to ordering races with sshd (tmpfiles may not complete before sshd starts)
3. **sshd-keygen script override + `Before=sshd.service`** — the service fails silently early in boot (possibly `/etc` not writable); root cause unclear but the `mkdir -p` before `rm -f` fix didn't resolve it

**What works:**
Use a **custom systemd service** (not tmpfiles, not sshd-keygen) that:
1. Generates the key at build time via `pkgs.runCommand`
2. Copies it to `/etc/ssh/` at boot with correct permissions
3. Runs `After=local-fs.target`, `Before=sshd.service`, `WantedBy=multi-user.target`

```nix
systemd.services.my-hostkey = {
  description = "VM SSH Host Key Setup";
  before = [ "sshd.service" ];
  after = [ "local-fs.target" ];
  wantedBy = [ "multi-user.target" ];
  serviceConfig.Type = "oneshot";
  script = ''
    mkdir -p /etc/ssh
    cp -f ${hostKey}/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key
    chmod 0600 /etc/ssh/ssh_host_ed25519_key
  '';
};
```

Also override `environment.etc."ssh/ssh_host_ed25519_key.pub".text` with the generated pubkey using `mkForce` to avoid conflict with the machine config's hardcoded pubkey.

**Key insights:**
- `Before=sshd.service` on a custom service correctly orders it before sshd in systemd's graph (systemd mirrors `Before/After` bidirectionally)
- `After=local-fs.target` ensures `/etc/ssh/` is writable (not a concern on most systems, but early boot ordering can be fragile)
- `RequiredBy = [ "sshd.service" ]` is NOT needed — `wantedBy = [ "multi-user.target" ]` with `Before` is sufficient

---

## Initrd Bind Mount Fstab Bug

**Problem:** Persistence bind mounts fail in systemd-initrd with errors like `failed to mount /sysroot/var/lib/bluetooth`. The initrd-fstab was generated with `device="none"` for bind mounts:

```
none /var/lib/bluetooth none x-initrd.mount 0 0
```

**Root cause:** `src/nixos/modules/system/impermenance/system-impermenance.nix` had:
```nix
device = lib.mkDefault "none";  # WRONG
```
And was missing `options = [ "bind" ]`. This meant systemd-fstab-generator created mount units with `What=none` instead of the actual bind source path.

**Fix:** Compute the correct device path from `persistentStoragePath + sourcePath`:
```nix
device = "${psp}${sourcePath}";
options = lib.mkDefault [ "bind" ];
```

This produces correct fstab entries:
```
/nix/persist/system/var/lib/bluetooth /var/lib/bluetooth none bind 0 0
```

**Why the vendored impermanence's `boot.initrd.systemd.mounts` didn't help:** They created correct static mount units, but systemd-fstab-generator overrides static mount units with generated ones from fstab. The broken fstab entries (with `device=none`) took precedence and broke the boot.

**Verification:** Check the initrd fstab in the nix store:
```sh
cat /nix/store/*-initrd-fstab | grep -E '^none /var'
```
No `none /var/...` entries should remain. All persistence bind mounts must show the correct source path.

**Double-concern:** The `fileSystems` entries from `system-impermanence.nix` and the `boot.initrd.systemd.mounts` from vendored impermanence create duplicate mount units. This is safe because systemd-fstab-generator overrides static units. If ordering issues arise, remove the duplicate from `vendor/impermanence/nixos.nix`.

---

## agenix Fork Spec Architecture (July 2026)

The NiXium agenix fork (`vendor/agenix/`) has comprehensive specs embedded as `###!` comments:
- `vendor/agenix/modules/age.nix` (848 lines) — System-level secrets
- `vendor/agenix/modules/age-home.nix` (475 lines) — User-level secrets

Key decisions: persistent agenix-agent with mlocked IdentityKey, Unix socket, get-secret subcommand. No /run/agenix ramfs — secrets piped directly to target paths. Anchored regex check validates completeness. Injection model with auto-derived placeholders from check presets. Exit codes 0/1/2/4. Ghost Identity pipeline with encrypted salt for HNDL defense. Anti-TPM, FIDO2 preferred. Upstream code preserved as reference below specs.
