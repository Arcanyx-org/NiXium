{ self, inputs, lib, ... }:

###! # Global Module for Monero
###!
###! Monero node persistence: persists the monero data directory when
###! impermanence is enabled.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the monero
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-services-monero-vm
###!
###! Inside the VM: check monero service configuration.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.services-monero = ./services-monero.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "services-monero-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/services/monero";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Enable services.monero so the module applies.
						# services.monero.enable = true;
					};
				};
			in {
				packages."nixos-services-monero-vm" = vm.vm;
				apps."nixos-services-monero-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-services-monero-vm";
				};
			};
	}
]
