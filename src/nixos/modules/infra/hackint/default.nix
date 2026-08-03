{ self, inputs, lib, ... }:

###! # Global Module for Hackint Infrastructure
###!
###! hackint.org infrastructure: Tor MapAddress for the IRCD
###! (guybrush.hackint.org → .onion).
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the hackint
###! infrastructure config can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-infra-hackint-vm
###!
###! Inside the VM: inspect tor MapAddress configuration.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.infra-hackint = ./infra-hackint.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "infra-hackint-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/infra/hackint";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Enable tor so the MapAddress takes effect.
					};
				};
			in {
				packages."nixos-infra-hackint-vm" = vm.vm;
				apps."nixos-infra-hackint-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-infra-hackint-vm";
				};
			};
	}
]
