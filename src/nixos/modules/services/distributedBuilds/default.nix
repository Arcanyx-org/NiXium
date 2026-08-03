{ self, inputs, lib, ... }:

###! # Global Module for Distributed Builds
###!
###! Sets up the `builder` user used for distributed Nix builds and authorizes
###! it as a trusted user in the nix daemon.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the distributed
###! builds configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-services-distributedBuilds-vm
###!
###! Inside the VM: check the builder user exists and the nix trusted-users
###! setting.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.services-distributedBuilds = ./services-distributedBuilds.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "services-distributedBuilds-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/services/distributedBuilds";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Enable nix.distributedBuilds so the module applies.
						# nix.distributedBuilds = true;
					};
				};
			in {
				packages."nixos-services-distributedBuilds-vm" = vm.vm;
				apps."nixos-services-distributedBuilds-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-services-distributedBuilds-vm";
				};
			};
	}
]
