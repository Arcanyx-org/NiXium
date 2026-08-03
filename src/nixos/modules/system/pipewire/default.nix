{ self, inputs, lib, ... }:

###! # Global Module for PipeWire
###!
###! Enables avahi for service discovery and RAOP/AirPlay discovery via the
###! raop-discover module when PipeWire is enabled.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the PipeWire
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-system-pipewire-vm
###!
###! Inside the VM: check pipewire config and avahi status.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.system-pipewire = ./system-pipewire.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "system-pipewire-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/system/pipewire";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Enable services.pipewire so the module applies.
						# services.pipewire.enable = true;
					};
				};
			in {
				packages."nixos-system-pipewire-vm" = vm.vm;
				apps."nixos-system-pipewire-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-system-pipewire-vm";
				};
			};
	}
]
