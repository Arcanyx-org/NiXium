{ self, inputs, lib, ... }:

###! # Global Module for DebugFS Restriction
###!
###! Restricts debugfs and tracefs to root-only to prevent leaking kernel
###! internals (tracing data, process names, kernel addresses) to unprivileged
###! users.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the debugfs
###! restriction service can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-security-debugfs-vm
###!
###! Inside the VM: check the restrict-debugfs service status and permissions on
###! /sys/kernel/debug and /sys/kernel/tracing.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.security-debugfs = ./security-debugfs.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "security-debugfs-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/security/debugfs";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Adjust module-specific options for the test VM.
					};
				};
			in {
				packages."nixos-security-debugfs-vm" = vm.vm;
				apps."nixos-security-debugfs-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-security-debugfs-vm";
				};
			};
	}
]
