{ self, inputs, lib, ... }:

###! # Global Module for OpenSnitch
###!
###! Application firewall policy: deny-by-default with allow rules for
###! systemd-timesyncd, systemd-resolved, cupsd, nsncd and tor; blocks
###! gnome-calculator from network access.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the OpenSnitch
###! rules can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-services-opensnitch-vm
###!
###! Inside the VM: check the loaded opensnitch rules.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.services-opensnitch = ./services-opensnitch.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "services-opensnitch-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/services/opensnitch";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Enable services.opensnitch so the module applies.
						# services.opensnitch.enable = true;
					};
				};
			in {
				packages."nixos-services-opensnitch-vm" = vm.vm;
				apps."nixos-services-opensnitch-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-services-opensnitch-vm";
				};
			};
	}
]
