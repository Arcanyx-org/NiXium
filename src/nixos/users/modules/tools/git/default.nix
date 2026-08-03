{ lib, self, inputs, ... }:

###! # Home Module for Git
###!
###! Provides git to all users by default (home-manager level).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-tools-git-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.tools-git = ./git.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-tools-git-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/modules/tools/git";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.tools-git ];
					homeManagerConfig = { programs.git.enable = true; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-tools-git-vm" = vm.vm;
				apps."nixos-home-tools-git-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-tools-git-vm";
				};
			};
	}
]
