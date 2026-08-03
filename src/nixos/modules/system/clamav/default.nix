{ self, inputs, lib, ... }:

###! # Global Module for ClamAV
###!
###! Installs clamtk, enables the ClamAV signature updater with restart on
###! failure, an OpenSnitch allow rule for freshclam and impermanence
###! persistence of the signature database.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the ClamAV
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-system-clamav-vm
###!
###! Inside the VM: check the clamav daemon/updater configuration.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.system-clamav = ./system-clamav.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "system-clamav-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/system/clamav";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Enable services.clamav.daemon so the module applies.
						# services.clamav.daemon.enable = true;
					};
				};
			in {
				packages."nixos-system-clamav-vm" = vm.vm;
				apps."nixos-system-clamav-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-system-clamav-vm";
				};
			};
	}
]
