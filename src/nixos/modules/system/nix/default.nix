{ self, inputs, lib, ... }:

###! # Global Module for Nix
###!
###! Global nix daemon configuration: nixPath + flake registry across releases,
###! abort-on-warn, experimental features, auto-optimise, GC schedule, and
###! impermanence persistence of profiles.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the nix
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-system-nix-vm
###!
###! Inside the VM: check nix.conf / flake registry.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.system-nix = ./system-nix.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "system-nix-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/system/nix";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Adjust module-specific options for the test VM.
					};
				};
			in {
				packages."nixos-system-nix-vm" = vm.vm;
				apps."nixos-system-nix-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-system-nix-vm";
				};
			};
	}
]
