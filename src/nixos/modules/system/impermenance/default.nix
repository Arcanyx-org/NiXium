{ self, inputs, lib, ... }:

###! # Global Module for Impermanence
###!
###! Central impermanence glue: creates persistent user directories with
###! correct ownership, generates tmpfiles rules for all persistence source
###! paths (system + home-manager stores) and the initrd bind-mount fstab.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the impermanence
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-system-impermenance-vm
###!
###! Inside the VM: inspect generated tmpfiles rules and persistence mounts.
###! NOTE: mkVM disables boot.impermanence by default.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.system-impermenance = ./system-impermenance.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "system-impermenance-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/system/impermenance";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Enable boot.impermanence + persistence stores to test.
					};
				};
			in {
				packages."nixos-system-impermenance-vm" = vm.vm;
				apps."nixos-system-impermenance-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-system-impermenance-vm";
				};
			};
	}
]
