{ self, inputs, lib, ... }:

###! # Global Module for AppImage Management
###!
###! AppImages are designed for systems following the Filesystem Hierarchy Standard (FHS). Since NixOS utilizes a unique /nix/store structure, AppImages cannot natively locate required dynamic linkers and shared libraries (e.g., glibc, libstdc++).
###!
###! This module provides a bridge for AppImage execution and system integration by:
###! * 1. Implementing 'appimage-run' to emulate a transient FHS environment.
###! * 2. Managing necessary FHS-compatible shared library paths for binary execution.
###! * 3. Handling desktop integration to ensure seamless launcher support.
###!
###! ### PROJECTED USAGE
###! a. Run any AppImage via CLI: `appimage-run path/to/app.AppImage`
###! b. Execute directly via binfmt_misc registrations configured within this module.
###!
###! ### TECHNICAL NOTE:
###! * This approach bypasses the need for manual 'patchelf' operations, preserving the integrity of the original AppImage binary while ensuring NixOS compatibility.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell and networking enabled,
###! so AppImages can be downloaded and tested without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-programs-appimage-vm
###!
###! Inside the VM: `appimage-run path/to/app.AppImage`.  If an AppImage fails,
###! adjust `extraPkgs` in `./programs-appimage.nix` and re-run.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.programs-appimage = ./programs-appimage.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "programs-appimage-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/programs/appimage";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true; # Whether to enable networking
					systemConfig = {
						programs.appimage.enable = true;

						# Fetching AppImages inside the VM
						environment.systemPackages = [ pkgs.curl pkgs.wget ];
					};
				};
			in {
				packages."nixos-programs-appimage-vm" = vm.vm;
				apps."nixos-programs-appimage-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-programs-appimage-vm";
				};
			};
	}
]
