{ self, inputs, lib, ... }:

###! # Global Module for Kernel
###!
###! Hardens the kernel: locks kernel modules and protects the kernel image
###! by default.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the kernel
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-system-kernel-vm
###!
###! Inside the VM: check the applied kernel hardening.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.system-kernel = ./system-kernel.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "system-kernel-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/system/kernel";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Adjust module-specific options for the test VM.
					};
				};
			in {
				packages."nixos-system-kernel-vm" = vm.vm;
				apps."nixos-system-kernel-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-system-kernel-vm";
				};
			};
	}
]
