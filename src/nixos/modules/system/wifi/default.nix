{ self, inputs, lib, ... }:

###! # Global Module for WiFi
###!
###! Authenticates all systems to Kreyren's hidden home WiFi network via an age
###! secret (NetworkManager connection profile).
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the WiFi
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-system-wifi-vm
###!
###! Inside the VM: check the NetworkManager connection profile.
###! NOTE: requires the home-wifi-psk age secret.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.system-wifi = ./system-wifi.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "system-wifi-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/system/wifi";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Enable networking.networkmanager so the module applies.
						# networking.networkmanager.enable = true;
					};
				};
			in {
				packages."nixos-system-wifi-vm" = vm.vm;
				apps."nixos-system-wifi-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-system-wifi-vm";
				};
			};
	}
]
