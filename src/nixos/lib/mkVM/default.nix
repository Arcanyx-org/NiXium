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
###! ## CLOSURE DEPENDENCIES
###!
###! This file is imported as: `mkVM = import ./path/to/mkVM { inherit lib inputs self; };`
###! The lib, inputs, and self arguments are baked into the closure — call sites
###! do NOT pass them.  This avoids the namespace pollution and evaluation-order
###! issues of config._module.args.  See .opencode/quests/module-args-vs-let-inherit.md
###! for the full rationale.
###!
###! ## PUBLIC API: mkVM
###!
###! mkVM is the ONLY public function.  It returns a record with two building
###! blocks — the call site decides what to expose:
###!
###!   let vm = mkVM { inherit pkgs system; name = "editors-vim-kreyren"; ... }; in
###!   {
###!     packages."nixos-vm-editors-vim-kreyren" = vm.vm;
###!     apps."nixos-vm-editors-vim-kreyren" = {
###!       type = "app";
###!       program = "${vm.runner}/bin/nixos-vm-editors-vim-kreyren";
###!     };
###!   }
###!
###! This design is framework-agnostic: mkVM returns plain derivations, not
###! flake-parts-specific structures.  External flakes use it the same way.
###!
###! ## RETURN VALUE
###!
###!   {
###!     vm = <derivation>;      # vmSystem.config.system.build.vm — the raw NixOS VM image
###!     runner = <derivation>;  # writeShellApplication — custom runner with disk strategy,
###!                            # GPU passthrough, timeout, exit code propagation
###!   }
###!
###! vm — the raw NixOS VM derivation.  Pass to QEMU directly, hand to upstream
###! developers for reproduction, or build with `nix build`.
###!
###! runner — the opinionated wrapper.  Handles 3-mode disk strategy, GPU passthrough,
###! timeout, exit code propagation.  Use for `nix run` apps and CI checks.
###!
###! ## PARAMETERS
###!
###! ### Identity
###!
###! name (required)
###!   String used in the runner binary name and disk image filename.
###!   Example: "editors-vim-kreyren"
###!   Produces runner: nixos-vm-editors-vim-kreyren
###!   Produces disk:   ${modulePath}/editors-vim-kreyren.qcow2
###!   NOTE: The call site chooses the packages/apps/checks key names, not mkVM.
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
###! pkgs ? null
###!   nixpkgs package set for the guest system.  When null (the default),
###!   mkVM creates a vanilla import: `import inputs.nixpkgs { system = guestSystem; }`.
###!   Override for unfree packages, overlays, or a different nixpkgs version.
###!
###!   DESIGN DECISION: pkgs ? null instead of a locked-down default or a
###!   boolean allowUnfree parameter.
###!   Rationale: A boolean allowUnfree is a false abstraction — it covers one
###!   config key while ignoring permittedInsecurePackages, overlays, nixpkgs
###!   version, etc.  Users need full pkgs control for testing different nixpkgs
###!   versions (stable vs unstable), overlays, and all nixpkgs configuration.
###!   The vanilla default gives both simplicity and flexibility.
###!
###!   Examples:
###!     pkgs = null;                                                    # vanilla default
###!     pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };     # explicit system
###!     pkgs = import inputs.nixpkgs {                                  # unfree + overlay
###!       system = "x86_64-linux";
###!       config.allowUnfree = true;
###!       overlays = [ myOverlay ];
###!     };
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
###! Mode 1: Developer mode ($FLAKE_ROOT is a valid directory)
###!   Disk: ${modulePath}/${name}.qcow2
###!   Behavior: Persistent.  Changes survive across VM runs.
###!   Use case: Iterative development within the NiXium repo.
###!
###! Mode 2: User override ($NIX_DISK_IMAGE set, FLAKE_ROOT not a valid dir)
###!   Disk: Whatever $NIX_DISK_IMAGE points to
###!   Behavior: Persistent at user-chosen path.
###!   Use case: Running from outside the repo with a custom disk location.
###!   Also catches the edge case where FLAKE_ROOT is set but points to a
###!   non-existent directory (stale env var).
###!
###! Mode 3: Ephemeral (neither condition met)
###!   Disk: ${TMPDIR:-/var/tmp}/nixium-vm-${name}.qcow2 + QEMU -snapshot
###!   Behavior: Stateless.  QEMU COW overlay is unlink()'d immediately;
###!            kernel reclaims space on VM exit even under SIGKILL.
###!   Use case: CI, one-off testing, external users.
###!
###! DESIGN DECISION: FLAKE_ROOT checked first for performance.
###!   When running from the repository (the common case), FLAKE_ROOT is always
###!   set by direnv/nix develop.  Checking it first avoids wasting CPU cycles
###!   on unnecessary checks.  NIX_DISK_IMAGE is checked second, which also
###!   catches the edge case where FLAKE_ROOT is stale (set but non-existent).
###!
###! DESIGN DECISION: ${TMPDIR:-/var/tmp} for ephemeral disk.
###!   /var/tmp is the FHS convention for persistent temp storage, but it
###!   doesn't exist on macOS or some non-FHS systems.  TMPDIR is set by the
###!   system on macOS (/var/folders/.../T/) and by users on custom Linux
###!   setups.  If TMPDIR is set to /tmp (often tmpfs/RAM-backed), the runner
###!   warns the user that large VM overlays may cause OOM pressure.
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
###!   let inherit (self.lib) mkVM; in
###!   { perSystem = { system, pkgs, ... }:
###!       let vm = mkVM {
###!         inherit pkgs system;
###!         name = "editors-vim-kreyren";
###!         command = "vim";
###!         modulePath = "$FLAKE_ROOT/src/nixos/.../vim";
###!         graphical = "wayland";
###!         homeManagerModules = [ self.homeManagerModules.editors-vim-kreyren ];
###!         homeManagerConfig = { programs.vim.enable = true; };
###!       }; in {
###!         packages."nixos-vm-editors-vim-kreyren" = vm.vm;
###!         apps."nixos-vm-editors-vim-kreyren" = {
###!           type = "app";
###!           program = "${vm.runner}/bin/nixos-vm-editors-vim-kreyren";
###!         };
###!       };
###!   }
###!
###! CLI test — automated, exits with code:
###!   let inherit (self.lib) mkVM; in
###!   { perSystem = { system, pkgs, ... }:
###!       let vm = mkVM {
###!         inherit pkgs system;
###!         name = "editors-vim-kreyren-test";
###!         command = "vim -c checkhealth -c qa!";
###!         modulePath = "$FLAKE_ROOT/src/nixos/.../vim";
###!         graphical = null;
###!         exitMode = "propagate";
###!         timeout = 60;
###!         homeManagerModules = [ self.homeManagerModules.editors-vim-kreyren ];
###!         homeManagerConfig = { programs.vim.enable = true; };
###!       }; in {
###!         checks."editors-vim-kreyren" = pkgs.runCommand "check-editors-vim-kreyren" {} ''
###!           timeout 60 ${vm.runner}/bin/nixos-vm-editors-vim-kreyren-test
###!           touch $out
###!         '';
###!       };
###!   }
###!
###! Interactive dev — no timeout, shell access:
###!   let inherit (self.lib) mkVM; in
###!   { perSystem = { system, pkgs, ... }:
###!       let vm = mkVM {
###!         inherit pkgs system;
###!         name = "editors-vim-kreyren-dev";
###!         command = "vim";
###!         modulePath = "$FLAKE_ROOT/src/nixos/.../vim";
###!         graphical = "wayland";
###!         exitMode = "shell";
###!         timeout = null;
###!         homeManagerModules = [ self.homeManagerModules.editors-vim-kreyren ];
###!         homeManagerConfig = { programs.vim.enable = true; };
###!       }; in {
###!         apps."nixos-vm-editors-vim-kreyren-dev" = {
###!           type = "app";
###!           program = "${vm.runner}/bin/nixos-vm-editors-vim-kreyren-dev";
###!         };
###!       };
###!   }
###!
###! GPU passthrough — gaming VM:
###!   let inherit (self.lib) mkVM; in
###!   { perSystem = { system, pkgs, ... }:
###!       let vm = mkVM {
###!         inherit pkgs system;
###!         name = "skyrim-modpack";
###!         command = "...";
###!         modulePath = "$FLAKE_ROOT/src/nixos/.../skyrim";
###!         graphical = "wayland";
###!         exitMode = "shell";
###!         timeout = null;
###!         gpuPassthrough = "auto";
###!         systemConfig = {
###!           services.sunshine.enable = true;
###!           networking.firewall.allowedTCPPorts = [ 47989 47990 48010 ];
###!         };
###!       }; in {
###!         packages."nixos-vm-skyrim-modpack" = vm.vm;
###!         apps."nixos-vm-skyrim-modpack" = {
###!           type = "app";
###!           program = "${vm.runner}/bin/nixos-vm-skyrim-modpack";
###!         };
###!       };
###!   }
###!
###! Package only — hand VM image to upstream:
###!   let inherit (self.lib) mkVM; in
###!   { perSystem = { system, pkgs, ... }:
###!       let vm = mkVM {
###!         inherit pkgs system;
###!         name = "quest3-debug";
###!         command = "bash";
###!         modulePath = "$FLAKE_ROOT/src/nixos/.../quest3";
###!         graphical = null;
###!         exitMode = "shell";
###!         timeout = null;
###!       }; in {
###!         packages."nixos-vm-quest3-debug" = vm.vm;
###!       };
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
###!                         build parameter via ${GPU_PASSTHROUGH:-$GPU_PASSTHROUGH_DEFAULT}.
###!   QEMU_OPTS           — Additional QEMU flags (appended to built-in flags).
###!   $@                  — Any arguments passed after -- in nix run command.
###!
###! ### GPU Passthrough Priority
###!
###! Priority: GPU_PASSTHROUGH env var > gpuPassthrough build param > null
###!
###! Implemented via `GPU_PASSTHROUGH_DEFAULT` in runtimeEnv (not
###! `GPU_PASSTHROUGH` directly, because runtimeEnv hard-assignment would
###! overwrite the user's runtime value).  The script uses POSIX parameter
###! expansion: `${GPU_PASSTHROUGH:-$GPU_PASSTHROUGH_DEFAULT}`.
###!
###! ### Disk Strategy Priority
###!
###! The three disk modes are mutually exclusive with FLAKE_ROOT checked first
###! to optimize for the common case (running from the repository):
###!   Priority 1: FLAKE_ROOT is a valid directory → dev mode, persist next to module
###!   Priority 2: NIX_DISK_IMAGE is set → user override, use as-is
###!   Priority 3: Neither → ephemeral, ${TMPDIR:-/var/tmp} with -snapshot
###!
###! NOTE: When running from the repository, FLAKE_ROOT is always set by
###! direnv/nix develop, so NIX_DISK_IMAGE cannot override in that context.
###! This is acceptable for the current use case.
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

{ lib, inputs, self }:

let
	inherit (lib) mkDefault mkForce mkMerge concatStringsSep optional optionalString;
	inherit (builtins) elem getName;

	# -------------------------------------------------------------------------
	# mkWaylandKioskModule
	#
	# Returns a NixOS module configuring a minimal Wayland kiosk:
	#   greetd → cage → foot -e <command>
	#
	# Parameters:
	#   pkgs    — nixpkgs for the guest system
	#   user    — username to autologin as
	#   command — string command to run inside foot
	# -------------------------------------------------------------------------
	mkWaylandKioskModule = { pkgs, user, command }: {
		# cage: Wayland kiosk compositor — runs one maximized app, exits when it closes
		# foot: Fast Wayland-native terminal emulator
		# greetd: Lightweight display manager with autologin support
		services.greetd = {
			enable = true;
			settings.default_session = {
				command = "${pkgs.cage}/bin/cage -- ${pkgs.foot}/bin/foot -e ${command}";
				inherit user;
			};
		};

		# greetd restarts on failure by default; cage exits when the command closes,
		# which triggers restart loops in a kiosk context — disable it.
		systemd.services.greetd.serviceConfig.Restart = mkForce "no";

		# Dark monospace theme suitable for code editors and terminal tools
		environment.etc."xdg/foot/foot.ini".text = concatStringsSep "\n" [
			"[main]"
			"font=monospace:size=12"
			""
			"[colors]"
			"background=1a1a1a"
			"foreground=dcdccc"
		];

		# Graphics required for Wayland compositor
		virtualisation.vmVariant.virtualisation.graphics = true;
	};

	# -------------------------------------------------------------------------
	# mkXorgKioskModule
	#
	# Returns a NixOS module configuring a minimal X11 kiosk:
	#   xinit → startx → xterm -e <command>
	#
	# The autologin service starts X as the given user on tty1.
	#
	# Parameters:
	#   pkgs    — nixpkgs for the guest system
	#   user    — username to autologin as
	#   command — string command to run inside xterm
	# -------------------------------------------------------------------------
	mkXorgKioskModule = { pkgs, user, command }: {
		# xterm: classic X11 terminal, universally available
		services.xserver = {
			enable = true;
			# Disable display manager; we drive X manually via startx autologin
			displayManager.startx.enable = true;
		};

		# Autologin service: starts X as <user> on tty1, runs xterm -e <command>
		systemd.services."xorg-kiosk-autologin" =
			let
				startScript = pkgs.writeShellApplication {
					name = "xorg-kiosk-autologin";
					runtimeInputs = [ pkgs.xorg.xinit pkgs.xterm ];
					bashOptions = [ "errexit" ];
					text = "exec xinit ${pkgs.xterm}/bin/xterm -e ${command} -- :0 vt1";
				};
			in {
				description = "Xorg kiosk autologin for ${user}";
				wantedBy = [ "multi-user.target" ];
				after = [ "systemd-user-sessions.service" "getty@tty1.service" ];
				conflicts = [ "getty@tty1.service" ];
				serviceConfig = {
					# ExecStart expects a string path; interpolate the derivation
					ExecStart = "${startScript}/bin/xorg-kiosk-autologin";
					User = user;
					PAMName = "login";
					TTYPath = "/dev/tty1";
					StandardInput = "tty";
					StandardOutput = "tty";
					StandardError = "journal";
					UtmpIdentifier = "tty1";
					UtmpMode = "user";
					Restart = "no";
				};
			};

		# Graphics required for X11
		virtualisation.vmVariant.virtualisation.graphics = true;
	};

	# -------------------------------------------------------------------------
	# mkCliAutologinModule
	#
	# Returns a NixOS module configuring CLI autologin on tty1 with command
	# execution and exit behaviour controlled by exitMode.
	#
	# exitMode = "propagate":
	#   Captures exit code, writes to isa-debug-exit port 0xf4, then poweroff.
	#   Runner decodes: HOST_EXIT = (QEMU_EXIT - 1) >> 1
	#
	# exitMode = "poweroff":
	#   Runs command, then powers off regardless of exit code.
	#
	# exitMode = "shell":
	#   Runs command, then drops to interactive bash.
	#
	# Parameters:
	#   pkgs     — nixpkgs for the guest system
	#   user     — username to autologin as
	#   command  — string command to run
	#   exitMode — "propagate" | "poweroff" | "shell"
	# -------------------------------------------------------------------------
	mkCliAutologinModule = { pkgs, user, command, exitMode }:
		let
			# Build the post-command action based on exitMode
			exitScript = {
				"propagate" = concatStringsSep "\n" [
					"# Write exit code to QEMU isa-debug-exit port 0xf4"
					"# QEMU encodes as: (code << 1) | 1"
					"# Runner decodes:  HOST_EXIT = (QEMU_EXIT - 1) >> 1"
					"printf '\\x%02x' \"$_cmd_exit\" | dd of=/dev/port bs=1 seek=$((0xf4)) 2>/dev/null || true"
					"poweroff -f"
				];
				"poweroff" = "poweroff -f";
				"shell" = "exec bash";
			}.${exitMode};

			autologinScript = pkgs.writeShellApplication {
				name = "cli-autologin-${user}";
				runtimeInputs = [ pkgs.coreutils ];
				bashOptions = [ "errexit" ];
				text = concatStringsSep "\n" [
					"${command}"
					"_cmd_exit=$?"
					exitScript
				];
			};
		in {
			# Override getty on tty1 to autologin and immediately run our script
			systemd.services."autologin-tty1" = {
				description = "CLI autologin and command runner for ${user} on tty1";
				wantedBy = [ "multi-user.target" ];
				after = [ "systemd-user-sessions.service" "getty@tty1.service" ];
				conflicts = [ "getty@tty1.service" ];
				serviceConfig = {
					ExecStart = "${autologinScript}/bin/cli-autologin-${user}";
					User = user;
					PAMName = "login";
					TTYPath = "/dev/tty1";
					StandardInput = "tty";
					StandardOutput = "tty";
					StandardError = "journal";
					UtmpIdentifier = "tty1";
					UtmpMode = "user";
					Restart = "no";
				};
			};

			# Disable graphical session; CLI mode only needs a console
			virtualisation.vmVariant.virtualisation.graphics = false;
		};

	# -------------------------------------------------------------------------
	# mkVmSystem
	#
	# Builds a NixOS system with standard NiXium boilerplate.
	# Callers supply only the modules that differ per VM.
	#
	# Parameters (all forwarded from mkVM):
	#   system, guestSystem, pkgs (already resolved — never null),
	#   user, userConfig, homeManagerModules, homeManagerConfig,
	#   systemConfig, extraModules, extraSpecialArgs,
	#   displayModule  — pre-built display NixOS module (from one of the mk*KioskModule helpers)
	#   memorySize, cores, diskSize
	#
	# Note: inputs and self are in closure scope, not passed as parameters.
	# -------------------------------------------------------------------------
	mkVmSystem = {
		system,
		guestSystem,
		pkgs,
		user,
		userConfig,
		homeManagerModules,
		homeManagerConfig,
		systemConfig,
		extraModules,
		extraSpecialArgs,
		displayModule,
		memorySize,
		cores,
		diskSize,
	}:
		inputs.nixpkgs.lib.nixosSystem {
			system = guestSystem;

			inherit pkgs;

			modules = [
				# NiXium global module
				self.nixosModules.default

				# Standard NiXium infrastructure modules
				self.inputs.ragenix.nixosModules.default
				self.inputs.sops.nixosModules.sops
				self.inputs.hm.nixosModules.home-manager
				self.inputs.disko.nixosModules.disko
				self.inputs.lanzaboote.nixosModules.lanzaboote
				self.inputs.impermanence.nixosModules.impermanence

				# Display module (wayland kiosk / xorg kiosk / CLI autologin)
				displayModule

				# Caller system-level config
				systemConfig

				# Core VM boilerplate
				{
					# Lanzaboote requires sbctl setup not available in VM
					boot.lanzaboote.enable = false;

					# Impermanence requires tmpfs root; not useful in ephemeral test VMs
					boot.impermanence.enable = mkForce false;

					# Serial console output for VM debugging
					boot.kernelParams = [ "console=ttyS0" ];

					# VFIO drivers always present so the image works with or without GPU passthrough
					boot.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];

					# Required for age secrets (ragenix) inside the VM
					age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
					services.openssh = {
						enable = true;
						settings = {
							PermitRootLogin = mkDefault "yes";
							PasswordAuthentication = mkDefault true;
						};
					};

				# Home-manager wiring
				# useGlobalPkgs/useUserPackages required for HM to access system packages
				home-manager = {
					useGlobalPkgs = mkDefault true;
					useUserPackages = mkDefault true;
					users.${user} = mkMerge [
						{ imports = homeManagerModules; }
						homeManagerConfig
						{
							# FIXME-UPSTREAM(Krey): HM doesn't recognise 26.05 yet; use last stable.
							home.stateVersion = mkDefault "25.11";
						}
					];
				};

					# Test user creation with safe defaults for VM use
					users.users.${user} = {
						description = mkDefault "Test User";
						uid = mkDefault 1000;
						isNormalUser = mkDefault true;
						createHome = mkDefault true;
						password = mkDefault "000000"; # Intentionally trivial for test VMs
						extraGroups = mkDefault [ "video" "wheel" ];
					} // userConfig;

					# VM resource allocation
					virtualisation.vmVariant.virtualisation = {
						memorySize = mkDefault memorySize;
						cores = mkDefault cores;
						diskSize = mkDefault diskSize;
					};

					# FIXME-UPSTREAM(Krey): HM doesn't recognise 26.05 yet; use last stable.
					system.stateVersion = mkDefault "25.11";
				}
			] ++ extraModules;

			specialArgs = {
				inherit self;
			} // extraSpecialArgs;
		};

	# -------------------------------------------------------------------------
	# mkVmRunner
	#
	# Creates a writeShellApplication that wraps the standalone runner.sh script.
	# The script handles:
	#   - 3-mode disk strategy (dev/user-override/ephemeral)
	#   - Architecture mismatch warning
	#   - GPU passthrough detection (auto / explicit PCI / disabled)
	#   - Timeout wrapper (optional)
	#   - Exit code propagation decoding
	#
	# All logic lives in runner.sh (included via builtins.readFile) so it can be
	# linted with shellcheck and edited with proper syntax highlighting.
	# Nix values are passed via runtimeEnv (not builtins.replaceStrings) because
	# runtimeEnv safely serializes values into environment variables.
	#
	# Parameters (all forwarded from mkVM):
	#   pkgs, name, system, guestSystem, modulePath,
	#   vmSystem      — built NixOS system from mkVmSystem
	#   gpuPassthrough — null | "auto" | "<pci-address>"
	#   extraQemuOptions — list of extra QEMU flag strings
	#   timeout       — integer seconds or null
	#   exitMode      — "propagate" | "poweroff" | "shell"
	# -------------------------------------------------------------------------
	mkVmRunner = {
		pkgs,
		name,
		system,
		guestSystem,
		modulePath,
		vmSystem,
		gpuPassthrough,
		extraQemuOptions,
		timeout,
		exitMode,
	}:
		let
			# isa-debug-exit is always added so propagate mode works even if the
			# user changes exitMode after building (forward-compat).
			isaDebugExitFlag = "-device isa-debug-exit,iobase=0xf4,iosize=0x04";

			# Bake build-time constants into EXTRA_QEMU_OPTS.  These are not
			# overridable at runtime — only values that need runtime override
			# belong in runtimeEnv.
			extraQemuOpts = concatStringsSep " " ([ isaDebugExitFlag ] ++ extraQemuOptions);
		in
			pkgs.writeShellApplication {
				name = "nixos-vm-${name}";
				runtimeInputs = with pkgs; [ coreutils pciutils util-linux qemu ];
				bashOptions = [ "errexit" "nounset" "pipefail" "posix" ];

				# runtimeEnv uses hard assignment (VAR='value'), which OVERWRITES any
				# user-set environment variable of the same name.  For variables that
				# need runtime override (like GPU_PASSTHROUGH), we use a _DEFAULT suffix
				# and POSIX parameter expansion in the script:
				#   ${GPU_PASSTHROUGH:-$GPU_PASSTHROUGH_DEFAULT}
				#
				# MODULE_PATH: modulePath contains "$FLAKE_ROOT/..." but $FLAKE_ROOT
				# is a runtime variable.  runtimeEnv would wrap it in single quotes,
				# preventing expansion.  We strip the "$FLAKE_ROOT/" prefix and store
				# only the relative path.  The runner reconstructs the full path as
				# ${FLAKE_ROOT}/${MODULE_PATH} at runtime.
				runtimeEnv = {
					VM_NAME = name;
					MODULE_PATH = builtins.substring (builtins.stringLength "$FLAKE_ROOT/") (builtins.stringLength modulePath - builtins.stringLength "$FLAKE_ROOT/") modulePath;
					GUEST_SYSTEM = guestSystem;
					VM_PATH = "${vmSystem.config.system.build.vm}/bin/run-nixos-vm";
					# _DEFAULT suffix because runtimeEnv would overwrite user's GPU_PASSTHROUGH
					GPU_PASSTHROUGH_DEFAULT = if gpuPassthrough == null then "" else gpuPassthrough;
					TIMEOUT = if timeout == null then "" else toString timeout;
					EXIT_MODE = exitMode;
					# Build-time constants baked in, not overridable at runtime
					EXTRA_QEMU_OPTS = extraQemuOpts;
				};

				text = builtins.readFile ./runner.sh;
			};

	# -------------------------------------------------------------------------
	# mkVM — PUBLIC API
	#
	# Returns a record with two building blocks:
	#   vm     — the raw NixOS VM derivation (vmSystem.config.system.build.vm)
	#   runner — the custom runner script (writeShellApplication)
	#
	# The call site decides what to expose as packages, apps, or checks.
	# -------------------------------------------------------------------------
	mkVM = {
		# Required
		pkgs ? null,
		system,
		name,
		command,
		modulePath,

		# Display
		graphical ? null,

		# Exit behaviour
		exitMode ? "propagate",
		timeout ? 300,

		# System
		systemConfig ? {},
		extraModules ? [],

		# Home-manager
		homeManagerModules ? [],
		homeManagerConfig ? {},

		# User
		user ? "Tester",
		userConfig ? {},

		# GPU passthrough (build-time default; runtime GPU_PASSTHROUGH overrides)
		gpuPassthrough ? null,

		# QEMU
		extraQemuOptions ? [],

		# Resources
		memorySize ? 1024 * 2,
		cores ? 2,
		diskSize ? 1024 * 5,

		# Advanced
		guestSystem ? system,
		extraSpecialArgs ? {},
	}:
		let
			# Resolve pkgs: when null, create a vanilla nixpkgs import for the guest system.
			# Users override for unfree packages, overlays, or different nixpkgs versions.
			resolvedPkgs =
				if pkgs == null then
					import inputs.nixpkgs { system = guestSystem; }
				else
					pkgs;

			# Resolve command to a string: derivations expose their bin path
			commandStr = if builtins.isString command
				then command
				else "${command}/bin/${command.meta.mainProgram or name}";

			# Select display module based on graphical parameter
			displayModule =
				if graphical == "wayland" then
					mkWaylandKioskModule { pkgs = resolvedPkgs; inherit user; command = commandStr; }
				else if graphical == "xorg" then
					mkXorgKioskModule { pkgs = resolvedPkgs; inherit user; command = commandStr; }
				else
					# graphical = null → CLI autologin
					mkCliAutologinModule { pkgs = resolvedPkgs; inherit user exitMode; command = commandStr; };

			# Build the NixOS guest system
			vmSystem = mkVmSystem {
				pkgs = resolvedPkgs;
				inherit system guestSystem user userConfig
					homeManagerModules homeManagerConfig systemConfig extraModules
					extraSpecialArgs displayModule memorySize cores diskSize;
			};

			# Build the runner script
			runner = mkVmRunner {
				pkgs = resolvedPkgs;
				inherit name system guestSystem modulePath vmSystem
					gpuPassthrough extraQemuOptions timeout exitMode;
			};
		in {
			# Raw NixOS VM derivation — pass to QEMU, hand to upstream, or build with nix build
			vm = vmSystem.config.system.build.vm;

			# Custom runner with disk strategy, GPU passthrough, timeout, exit code propagation
			runner = runner;
		};

in mkVM
