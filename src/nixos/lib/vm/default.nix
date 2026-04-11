###! # NiXium VM Library — Shared VM building utilities
###!
###! SUMMARY: mkVM — single-function interface for building NixOS test VMs with
###! Wayland/Xorg/CLI display, exit-code propagation, GPU passthrough, 3-mode
###! disk strategy, and per-module persistent storage.  Internal helpers
###! (mkVmSystem, mkVmRunner, mkWaylandKioskModule, mkCliAutologinModule,
###! mkXorgKioskModule) are not part of the public API.
###!
###! ## WHY THIS FILE EXISTS
###!
###! Before this library, every VM module (vim, nvim, etc.) contained ~140 lines
###! of nearly identical boilerplate: NixOS system definition, greetd/cage/foot
###! kiosk setup, user creation, home-manager wiring, VM resource allocation,
###! and a 3-mode disk runner script.  The only things that differed between
###! modules were the command name, the home-manager module, and disk size.
###! Adding a new VM meant copy-pasting all of that and changing 5 values.
###!
###! This library extracts the shared logic into mkVM, reducing each call site
###! from ~140 lines to ~15 lines while adding features the inline versions
###! lacked (exit-code propagation, GPU passthrough, CLI mode, timeout,
###! architecture warnings).
###!
###! ## PUBLIC API: mkVM
###!
###! mkVM is the ONLY public function.  It returns an attrset that merges
###! directly into a perSystem block:
###!
###!   perSystem = { system, pkgs, ... }:
###!     self.lib.vm.mkVM {
###!       inherit pkgs inputs self system;
###!       name = "editors-vim-kreyren";
###!       command = "vim";
###!       modulePath = "$FLAKE_ROOT/src/nixos/.../vim";
###!       graphical = "wayland";
###!       homeManagerModules = [ self.homeManagerModules.editors-vim-kreyren ];
###!       homeManagerConfig = { programs.vim.enable = true; };
###!     };
###!
###! ## PARAMETERS
###!
###! ### Identity
###!
###! name (required)
###!   String used in package/app names and disk image filename.
###!   Example: "editors-vim-kreyren"
###!   Produces: packages.nixos-vm-editors-vim-kreyren
###!             apps.nixos-vm-editors-vim-kreyren
###!
###! command (required)
###!   What the VM runs.  Can be a simple string ("vim") or a derivation
###!   (pkgs.writeShellApplication { ... }).  For automated testing, pass a
###!   command that exits with a non-zero code on failure — mkVM propagates
###!   the exit code to the host via isa-debug-exit when exitMode = "propagate".
###!
###!   Examples:
###!     command = "vim";                                    # interactive
###!     command = "vim -c checkhealth -c qa!";              # automated test
###!     command = pkgs.writeShellApplication { ... };        # complex script
###!
###! modulePath (required)
###!   Path where the dev-mode qcow2 disk image is stored.  Must start with
###!   $FLAKE_ROOT so the runner script can resolve it at runtime.
###!   Example: "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/editors/vim"
###!
###! guestSystem ? system
###!   Guest architecture.  Defaults to the host system (native).  Override for
###!   cross-architecture VMs (e.g., testing aarch64 on an x86_64 host).
###!   The runner script warns when guest ≠ host, since cross-arch emulation
###!   is slow and some features may not work.
###!
###!   Examples:
###!     guestSystem = system;              # native (default)
###!     guestSystem = "x86_64-linux";      # force x86_64 (for modules requiring it)
###!     guestSystem = "aarch64-linux";      # force aarch64
###!
###! ### Display
###!
###! graphical ? null
###!   Display mode for the VM:
###!     null       — CLI only.  Autologin on tty1, run command, then exit/shell.
###!                  Uses mkCliAutologinModule internally.
###!     "wayland"  — Wayland kiosk.  greetd → cage → foot → command.
###!                  Uses mkWaylandKioskModule internally.
###!     "xorg"     — X11 kiosk.  xinit → xterm -e command.
###!                  Uses mkXorgKioskModule internally.
###!
###!   DESIGN DECISION: Single parameter with null/wayland/xorg instead of
###!   three separate functions (mkVMGraphicalWayland, mkVMMinimal, etc.).
###!   Rationale: The three modes share 95% of their configuration.  Only the
###!   display module differs.  A single function with a dispatch parameter
###!   avoids code duplication and makes it obvious that the modes are related.
###!
###! ### Exit Behavior
###!
###! exitMode ? "propagate"
###!   What happens after the command exits:
###!     "propagate"  — Forward exit code to host via isa-debug-exit, then
###!                    power off.  The host process exits with the same code.
###!                    Ideal for automated testing and CI.
###!     "poweroff"   — Power off the VM after command exits.  Exit code is
###!                    lost.  Simple and predictable.
###!     "shell"      — Drop to an interactive shell after command exits.
###!                    For debugging and interactive development.
###!
###!   DESIGN DECISION: "propagate" is the default, not "poweroff" or "shell".
###!   Rationale: propagate is the safest default — the VM always exits and
###!   the host gets feedback.  For interactive dev, set exitMode = "shell"
###!   with timeout = null.
###!
###!   IMPLEMENTATION DETAILS:
###!   - "propagate": The command is wrapped in a script that captures the exit
###!     code, writes it to QEMU IO port 0xf4 (isa-debug-exit device), then
###!     calls poweroff.  QEMU exits with (code << 1) | 1.  The runner script
###!     decodes: HOST_EXIT = (QEMU_EXIT - 1) >> 1.
###!   - "poweroff": The command is wrapped with poweroff -f appended.
###!   - "shell": The command is run, then exec into bash.
###!   - All modes include the isa-debug-exit device in QEMU options so that
###!     propagate works even if the user changes exitMode at runtime (not
###!     currently supported, but forward-compatible).
###!
###! timeout ? 300
###!   Seconds before the VM is killed.  Prevents infinite hangs from bugs.
###!   Set to null to disable (for interactive dev sessions).
###!   Implemented via coreutils `timeout` wrapping the QEMU invocation.
###!   When timeout fires, the runner exits with code 124 (matching coreutils
###!   timeout convention).
###!
###!   DESIGN DECISION: 5-minute default (300 seconds).
###!   Rationale: Long enough for interactive testing, short enough to catch
###!   infinite hangs.  CI can set timeout = 60 for fast feedback.
###!
###! ### System Configuration (applied first)
###!
###! systemConfig ? {}
###!   NixOS module attrset merged at the system level.  The NixOS module
###!   system handles deep merging — no risk of clobbering nested attrsets.
###!   Use this for system-level config: services, networking, packages, etc.
###!
###!   Example:
###!     systemConfig = {
###!       environment.systemPackages = [ pkgs.vim ];
###!       networking.firewall.allowedTCPPorts = [ 8080 ];
###!     };
###!
###!   DESIGN DECISION: Separate systemConfig and homeManagerConfig instead of
###!   a single config parameter.
###!   Rationale: programs.vim.enable is a home-manager option, not a NixOS
###!   option.  A single config parameter would require knowing which options
###!   belong to which module system — impossible to determine statically.
###!   Two parameters make scope explicit and let the NixOS module system
###!   handle deep merging correctly for each scope.
###!
###! extraModules ? []
###!   Additional NixOS modules appended to the module list.  For anything
###!   that doesn't fit the convenience parameters.  Modules are merged by
###!   the NixOS module system with correct priority.
###!
###! ### Home-Manager (applied after system)
###!
###! homeManagerModules ? []
###!   List of home-manager modules to import for the test user.
###!   Example: [ self.homeManagerModules.editors-vim-kreyren ]
###!
###! homeManagerConfig ? {}
###!   Attrset merged into home-manager.users.<user>.  The NixOS module system
###!   handles deep merging.  Use for enabling programs, setting options, etc.
###!
###!   Example:
###!     homeManagerConfig = { programs.vim.enable = true; };
###!
###!   NOTE: This is scoped to the test user.  You don't write
###!   home-manager.users.Tester.programs.vim.enable — mkVM adds the
###!   user scoping automatically.
###!
###! ### User
###!
###! user ? "Tester"
###!   Username for the test user.  Used in home-manager scoping, greetd
###!   autologin, and user creation.
###!
###!   DESIGN DECISION: "Tester" instead of "kreyren" or "testuser".
###!   Rationale: "Tester" is generic (this is a library, not project-specific)
###!   and capitalized (conventional for NixOS user descriptions).  Call sites
###!   override with user = "kreyren" when needed.
###!
###! userConfig ? {}
###!   Attrset merged with the default user configuration.  The NixOS module
###!   system handles deep merging.  Defaults are set with lib.mkDefault so
###!   caller values take priority.
###!
###!   Default user config (all mkDefault):
###!     description = "Test User"
###!     uid = 1000
###!     isNormalUser = true
###!     createHome = true
###!     password = "000000"  # Intentionally simple for test VMs
###!     extraGroups = [ "video" "wheel" ]
###!
###! ### GPU Passthrough (build-time default)
###!
###! gpuPassthrough ? null
###!   Build-time default for GPU passthrough.  The runtime env var
###!   GPU_PASSTHROUGH takes precedence over this value.
###!
###!   Values:
###!     null          — No passthrough by default (most common)
###!     "auto"        — Auto-detect GPU at runtime
###!     "0000:01:00.0" — Explicit PCI address
###!
###!   DESIGN DECISION: Single env var GPU_PASSTHROUGH instead of two
###!   (GPU_PASSTHROUGH + GPU_PASSTHROUGH_DEVICE).
###!   Rationale: One concept, one variable.  "auto" for auto-detect,
###!   a PCI address for explicit, unset for disabled.  Simpler to document
###!   and remember.
###!
###!   RUNTIME BEHAVIOR (in the runner script):
###!   Priority: GPU_PASSTHROUGH env var > gpuPassthrough build param > null
###!
###!   GPU_PASSTHROUGH=auto:
###!     1. Check IOMMU support first (prerequisite for passthrough)
###!        - If /sys/kernel/iommu_groups doesn't exist or is empty, fail
###!          with instructions on how to enable IOMMU
###!     2. Detect all GPUs via lspci
###!     3. Show all found GPUs with PCI addresses
###!     4. Use first GPU, inform user which one was selected
###!     5. Tell user how to specify a different GPU
###!     6. If no GPU found, fail with instructions on manual specification
###!
###!   GPU_PASSTHROUGH=<pci-address>:
###!     Use the specified PCI address directly
###!
###!   GPU_PASSTHROUGH unset:
###!     No passthrough.  Print a tip about the feature on VM start.
###!
###!   PCI address normalization:
###!     lspci outputs short format (01:00.0), QEMU needs full format
###!     (0000:01:00.0).  The runner normalizes automatically.
###!
###!   IMPORTANT: The VM image always includes VFIO drivers and pciutils
###!   regardless of gpuPassthrough setting.  This means the same image works
###!   with or without passthrough — runtime env vars control behavior.
###!
###! ### QEMU
###!
###! extraQemuOptions ? []
###!
###!   Build-time QEMU flags baked into the runner script.  For flags that are
###!   part of the VM configuration (isa-debug-exit, etc.), not the host
###!   environment.
###!
###!   DESIGN DECISION: extraQemuOptions is the repository/module author's
###!   interface.  External users who run pre-built VMs use runtime mechanisms:
###!     - GPU_PASSTHROUGH env var (auto-detect or explicit PCI address)
###!     - QEMU_OPTS env var (additional QEMU flags)
###!     - $@ passthrough (nix run .#vm -- -enable-kvm)
###!   These compose, they don't overwrite:
###!     Final QEMU invocation = NixOS built-in opts + extraQemuOptions
###!       + GPU_PASSTHROUGH flags + QEMU_OPTS + "$@"
###!
###! ### Resources
###!
###! memorySize ? 1024 * 2  (2GB)
###! cores ? 2
###! diskSize ? 1024 * 5    (5GB)
###!
###! ### Advanced
###!
###! extraSpecialArgs ? {}
###!   Extra specialArgs passed to nixosSystem.  For modules that need access
###!   to flake inputs or other values not in the default set.
###!
###! ## DISK STRATEGY (3-mode)
###!
###! The runner script implements a 3-mode disk strategy:
###!
###! Mode 1: Developer mode ($FLAKE_ROOT set)
###!   Disk: ${modulePath}/${name}.qcow2
###!   Behavior: Persistent.  Changes survive across VM runs.
###!   Use case: Iterative development within the NiXium repo.
###!
###! Mode 2: User override ($NIX_DISK_IMAGE set)
###!   Disk: Whatever $NIX_DISK_IMAGE points to
###!   Behavior: Persistent at user-chosen path.
###!   Use case: Running from outside the repo with a custom disk location.
###!
###! Mode 3: Ephemeral (neither env var set)
###!   Disk: /var/tmp/nixium-vm-${name}.qcow2 + QEMU -snapshot
###!   Behavior: Stateless.  QEMU COW overlay is unlink()'d immediately;
###!            kernel reclaims space on VM exit even under SIGKILL.
###!   Use case: CI, one-off testing, external users.
###!
###! DESIGN DECISION: /var/tmp instead of /tmp.
###!   /tmp is often a tmpfs (RAM-backed).  QEMU overlays can grow large.
###!   /var/tmp is disk-backed, avoiding OOM pressure during long VM sessions.
###!
###! DESIGN DECISION: modulePath-based disk location in dev mode.
###!   Previous implementation used $FLAKE_ROOT/${name}.qcow2 (repo root),
###!   which cluttered the repo root with disk images.  Now disks live next
###!   to the module definition, keeping them organized and .gitignore-able.
###!
###! ## EXIT CODE PROPAGATION
###!
###! When exitMode = "propagate", the VM forwards the command's exit code to
###! the host process:
###!
###!   1. The command runs inside the VM
###!   2. A wrapper script captures the exit code
###!   3. The wrapper writes the code to QEMU IO port 0xf4 (isa-debug-exit)
###!   4. QEMU exits with (code << 1) | 1
###!   5. The runner script decodes: HOST_EXIT = (QEMU_EXIT - 1) >> 1
###!   6. The runner exits with HOST_EXIT
###!
###! This enables automated testing:
###!   nix run .#nixos-vm-editors-vim-kreyren
###!   echo $?  # Returns the vim command's exit code
###!
###! The isa-debug-exit device is always included in QEMU options regardless
###! of exitMode, for forward compatibility.
###!
###! ## ARCHITECTURE HANDLING
###!
###! guestSystem defaults to the host system (native execution).  Override for
###! cross-architecture VMs.
###!
###! The runner script detects architecture mismatch and warns:
###!   "WARNING: This VM is built for x86_64-linux but running on aarch64 host.
###!    Cross-architecture emulation will be slow. Some features may not work."
###!
###! NixOS's run-nixos-vm already selects the correct qemu-system-{arch}
###! binary based on the system parameter.  No hardcoding needed.
###!
###! For external users, Nix's standard mechanism handles architecture:
###!   nix run github:Arcanyx-org/NiXium#packages.aarch64-linux.nixos-vm-...
###!
###! ## ERROR MESSAGES
###!
###! All error messages are self-contained with actionable instructions.
###! No hardcoded repository URLs — they would be wrong for forks.
###! Instead, messages say "please report it to your NiXium provider's issue
###! tracker" and let the user find the correct URL.
###!
###! ## INTERNAL HELPERS (NOT PUBLIC API)
###!
###! mkVmSystem
###!   Builds a NixOS system with standard NiXium boilerplate (ragenix, sops,
###!   hm, disko, lanzaboote, impermanence, openssh).  Callers only supply the
###!   modules that differ per VM.
###!
###! mkVmRunner
###!   Creates a writeShellApplication implementing the 3-mode disk strategy,
###!   GPU passthrough detection, timeout wrapper, and exit code propagation.
###!
###! mkWaylandKioskModule
###!   Returns a NixOS module configuring greetd → cage → foot → command.
###!
###! mkCliAutologinModule
###!   Returns a NixOS module configuring autologin on tty1 with command
###!   execution and optional shell/poweroff on exit.
###!
###! mkXorgKioskModule
###!   Returns a NixOS module configuring xinit → xterm -e command.
###!
###! ## CALL SITE EXAMPLES
###!
###! Minimal — vim editor VM:
###!   mkVM {
###!     inherit pkgs inputs self system;
###!     name = "editors-vim-kreyren";
###!     command = "vim";
###!     modulePath = "$FLAKE_ROOT/src/nixos/.../vim";
###!     graphical = "wayland";
###!     homeManagerModules = [ self.homeManagerModules.editors-vim-kreyren ];
###!     homeManagerConfig = { programs.vim.enable = true; };
###!   }
###!
###! CLI test — automated, exits with code:
###!   mkVM {
###!     inherit pkgs inputs self system;
###!     name = "editors-vim-kreyren-test";
###!     command = "vim -c checkhealth -c qa!";
###!     modulePath = "$FLAKE_ROOT/src/nixos/.../vim";
###!     graphical = null;
###!     exitMode = "propagate";
###!     timeout = 60;
###!     homeManagerModules = [ self.homeManagerModules.editors-vim-kreyren ];
###!     homeManagerConfig = { programs.vim.enable = true; };
###!   }
###!
###! Interactive dev — no timeout, shell access:
###!   mkVM {
###!     inherit pkgs inputs self system;
###!     name = "editors-vim-kreyren-dev";
###!     command = "vim";
###!     modulePath = "$FLAKE_ROOT/src/nixos/.../vim";
###!     graphical = "wayland";
###!     exitMode = "shell";
###!     timeout = null;
###!     homeManagerModules = [ self.homeManagerModules.editors-vim-kreyren ];
###!     homeManagerConfig = { programs.vim.enable = true; };
###!   }
###!
###! GPU passthrough — gaming VM:
###!   mkVM {
###!     inherit pkgs inputs self system;
###!     name = "skyrim-modpack";
###!     command = "...";
###!     modulePath = "$FLAKE_ROOT/src/nixos/.../skyrim";
###!     graphical = "wayland";
###!     exitMode = "shell";
###!     timeout = null;
###!     gpuPassthrough = "auto";
###!     systemConfig = {
###!       services.sunshine.enable = true;
###!       networking.firewall.allowedTCPPorts = [ 47989 47990 48010 ];
###!     };
###!   }
###!
###! ## RUNTIME ENVIRONMENT VARIABLES
###!
###! These are read by the runner script at runtime, not at build time:
###!
###!   FLAKE_ROOT         — Dev mode disk strategy.  Set by direnv/nix develop.
###!   NIX_DISK_IMAGE      — User override for disk location.
###!   GPU_PASSTHROUGH     — "auto" for auto-detect, PCI address for explicit,
###!                         unset for no passthrough.  Overrides gpuPassthrough
###!                         build parameter.
###!   QEMU_OPTS           — Additional QEMU flags (appended to built-in flags).
###!   $@                  — Any arguments passed after -- in nix run command.
###!
###! ## DEFAULTS (all use lib.mkDefault for overridability)
###!
###!   system.stateVersion = "25.11"  (FIXME-UPSTREAM: HM doesn't recognize 26.05)
###!   home-manager.useGlobalPkgs = true
###!   home-manager.useUserPackages = true
###!   users.users.Tester.description = "Test User"
###!   users.users.Tester.uid = 1000
###!   users.users.Tester.isNormalUser = true
###!   users.users.Tester.createHome = true
###!   users.users.Tester.password = "000000"
###!   users.users.Tester.extraGroups = [ "video" "wheel" ]
###!   home-manager.users.Tester.home.stateVersion = "25.11"
