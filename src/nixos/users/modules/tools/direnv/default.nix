{ lib, self, inputs, ... }:

###! # Home Module for direnv
###!
###! Enables nix-direnv (with direnv) for all users.
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-tools-direnv-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.tools-direnv = ./direnv.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-tools-direnv-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/modules/tools/direnv";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.tools-direnv ];
					homeManagerConfig = { programs.direnv.enable = true; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-tools-direnv-vm" = vm.vm;
				apps."nixos-home-tools-direnv-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-tools-direnv-vm";
				};
			};
	}
]
