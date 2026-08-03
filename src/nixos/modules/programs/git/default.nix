{ self, inputs, lib, ... }:

###! # Global Module for Git
###!
###! System-wide git configuration: default branch naming, URL shorthands
###! (gh: / github: → https://github.com/), safe.directory for NiXium, and
###! OpenSnitch rules permitting git-remote-http over VPN.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell and networking enabled,
###! so git operations can be tested against remote repositories without touching
###! real hardware.
###!
###! Usage:
###!   nix run .#nixos-programs-git-vm
###!
###! Inside the VM: run git commands (git clone, git init, etc.).  If a remote
###! operation fails, adjust `programs.git.config` in `./programs-git.nix` and
###! re-run.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.programs-git = ./programs-git.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "programs-git-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/programs/git";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						programs.git.enable = true;
					};
				};
			in {
				packages."nixos-programs-git-vm" = vm.vm;
				apps."nixos-programs-git-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-programs-git-vm";
				};
			};
	}
]
