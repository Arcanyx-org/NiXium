{ lib, self, inputs, ... }:

###! # Home Module for Nix
###!
###! Enables nix-command/flakes experimental features and abort-on-warn in the
###! user-level nix configuration.
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-system-nix-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.system-nix = ./nix.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-system-nix-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/modules/system/nix";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.system-nix ];
					homeManagerConfig = { };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-system-nix-vm" = vm.vm;
				apps."nixos-home-system-nix-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-system-nix-vm";
				};
			};
	}
]
