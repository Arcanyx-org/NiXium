{ self, inputs, lib, ... }:

###! # Global Module for Locale
###!
###! Sets en_US.UTF-8 as the default locale with matching extra locale
###! settings and supported locales.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the locale
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-system-locale-vm
###!
###! Inside the VM: check the active locale settings (locale).

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.system-locale = ./system-locale.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "system-locale-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/system/locale";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Adjust module-specific options for the test VM.
					};
				};
			in {
				packages."nixos-system-locale-vm" = vm.vm;
				apps."nixos-system-locale-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-system-locale-vm";
				};
			};
	}
]
