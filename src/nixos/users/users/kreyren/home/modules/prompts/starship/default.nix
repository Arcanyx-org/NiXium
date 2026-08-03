{ lib, self, ... }:

###! # Home Module for Starship (kreyren)
###!
###! Kreyren's Starship prompt configuration (release-gated font packages).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-prompts-starship-kreyren-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.
###!
###! The module is gated on programs.starship.enable, enabled here via
###! homeManagerConfig so the release-appropriate branch activates.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.prompts-starship-kreyren = ./starship.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-prompts-starship-kreyren-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/prompts/starship";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.prompts-starship-kreyren ];
					homeManagerConfig = {
						programs.starship.enable = true;
					};
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-prompts-starship-kreyren-vm" = vm.vm;
				apps."nixos-home-prompts-starship-kreyren-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-prompts-starship-kreyren-vm";
				};
			};
	}
]
