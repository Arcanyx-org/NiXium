{ lib, self, ... }:

###! # Home Module for Alacritty (kreyren)
###!
###! Kreyren's Alacritty configuration (keyboard font-size bindings).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-terminal-emulators-alacritty-kreyren-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.terminal-emulators-alacritty-kreyren = ./alacritty.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-terminal-emulators-alacritty-kreyren-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/terminal-emulators/alacritty";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.terminal-emulators-alacritty-kreyren ];
					homeManagerConfig = {
						programs.alacritty.enable = true;
					};
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-terminal-emulators-alacritty-kreyren-vm" = vm.vm;
				apps."nixos-home-terminal-emulators-alacritty-kreyren-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-terminal-emulators-alacritty-kreyren-vm";
				};
			};
	}
]
