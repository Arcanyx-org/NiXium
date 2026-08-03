{ lib, self, inputs, ... }:

###! # Home Module for Alacritty
###!
###! Configures the default terminal shell for alacritty (bash), release-gated
###! for the `settings` option rename across releases.
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-terminal-emulators-alacritty-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot
###! (set `command = "alacritty"` to launch alacritty directly).

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.terminal-emulators-alacritty = ./alacritty.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-terminal-emulators-alacritty-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/modules/terminal-emulators/alacritty";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.terminal-emulators-alacritty ];
					homeManagerConfig = { programs.alacritty.enable = true; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-terminal-emulators-alacritty-vm" = vm.vm;
				apps."nixos-home-terminal-emulators-alacritty-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-terminal-emulators-alacritty-vm";
				};
			};
	}
]
