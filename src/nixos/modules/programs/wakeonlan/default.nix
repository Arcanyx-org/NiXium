{ self, inputs, lib, ... }:

###! # Global Module for wakeonlan
###!
###! System-wide wakeonlan configuration — installs wakeonlan on all systems.
###! NiXium dependency needed to awaken other systems (WOL magic packets).
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell and networking enabled,
###! so WOL packets can be sent and observed without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-programs-wakeonlan-vm
###!
###! Inside the VM: run `wakeonlan <mac-address>`.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.programs-wakeonlan = ./programs-wakeonlan.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "programs-wakeonlan-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/programs/wakeonlan";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						environment.systemPackages = [ pkgs.wakeonlan ];
					};
				};
			in {
				packages."nixos-programs-wakeonlan-vm" = vm.vm;
				apps."nixos-programs-wakeonlan-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-programs-wakeonlan-vm";
				};
			};
	}
]
