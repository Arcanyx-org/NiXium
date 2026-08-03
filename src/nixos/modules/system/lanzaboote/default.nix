{ self, inputs, lib, ... }:

###! # Global Module for Lanzaboote
###!
###! Configures Lanzaboote Secure Boot: disables systemd-boot, sets the sbctl
###! PKI bundle and persists it when impermanence is enabled.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the Lanzaboote
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-system-lanzaboote-vm
###!
###! Inside the VM: inspect boot loader configuration.
###! NOTE: mkVM disables boot.lanzaboote by default.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.system-lanzaboote = ./system-lanzaboote.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "system-lanzaboote-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/system/lanzaboote";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Enable boot.lanzaboote to test (requires Secure Boot setup).
					};
				};
			in {
				packages."nixos-system-lanzaboote-vm" = vm.vm;
				apps."nixos-system-lanzaboote-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-system-lanzaboote-vm";
				};
			};
	}
]
