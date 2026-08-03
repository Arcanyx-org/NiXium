{ self, inputs, lib, ... }:

###! # Global Module for Time
###!
###! Sets the default timezone to UTC.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the time
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-system-time-vm
###!
###! Inside the VM: check the active timezone (timedatectl).

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.system-time = ./system-time.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "system-time-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/system/time";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Adjust module-specific options for the test VM.
					};
				};
			in {
				packages."nixos-system-time-vm" = vm.vm;
				apps."nixos-system-time-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-system-time-vm";
				};
			};
	}
]
