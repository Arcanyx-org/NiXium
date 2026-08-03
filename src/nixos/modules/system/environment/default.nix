{ self, inputs, lib, ... }:

###! # Global Module for Environment
###!
###! Includes ~/.local/bin in PATH.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the environment
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-system-environment-vm
###!
###! Inside the VM: check the PATH handling for ~/.local/bin.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.system-environment = ./system-environment.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "system-environment-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/system/environment";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Adjust module-specific options for the test VM.
					};
				};
			in {
				packages."nixos-system-environment-vm" = vm.vm;
				apps."nixos-system-environment-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-system-environment-vm";
				};
			};
	}
]
