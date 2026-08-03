{ self, inputs, lib, ... }:

###! # Global Module for Docker
###!
###! Persists /var/lib/docker when impermanence is enabled.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the docker
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-system-docker-vm
###!
###! Inside the VM: check docker daemon configuration.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.system-docker = ./system-docker.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "system-docker-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/system/docker";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Enable virtualisation.docker so the module applies.
						# virtualisation.docker.enable = true;
					};
				};
			in {
				packages."nixos-system-docker-vm" = vm.vm;
				apps."nixos-system-docker-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-system-docker-vm";
				};
			};
	}
]
