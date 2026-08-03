{ self, inputs, lib, ... }:

###! # Global Module for Bootloader
###!
###! Skips the bootloader menu unless the spacebar is held during boot.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the bootloader
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-system-bootloader-vm
###!
###! Inside the VM: check the boot loader timeout.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.system-bootloader = ./system-bootloader.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "system-bootloader-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/system/bootloader";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Adjust module-specific options for the test VM.
					};
				};
			in {
				packages."nixos-system-bootloader-vm" = vm.vm;
				apps."nixos-system-bootloader-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-system-bootloader-vm";
				};
			};
	}
]
