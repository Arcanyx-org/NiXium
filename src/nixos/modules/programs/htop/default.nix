{ self, inputs, lib, ... }:

###! # Global Module for htop
###!
###! System-wide htop configuration — installs htop on all systems.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so htop can be
###! inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-programs-htop-vm
###!
###! Inside the VM: run `htop`.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.programs-htop = ./programs-htop.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "programs-htop-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/programs/htop";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						environment.systemPackages = [ pkgs.htop ];
					};
				};
			in {
				packages."nixos-programs-htop-vm" = vm.vm;
				apps."nixos-programs-htop-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-programs-htop-vm";
				};
			};
	}
]
