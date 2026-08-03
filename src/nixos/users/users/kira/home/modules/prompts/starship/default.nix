{ lib, self, ... }:

###! # Home Module for Starship (kira)
###!
###! Kira's starship prompt configuration (release-gated for the nerdfonts
###! package rename across releases).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-prompts-starship-kira-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.prompts-starship-kira = ./starship.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-prompts-starship-kira-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kira/home/modules/prompts/starship";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.prompts-starship-kira ];
					homeManagerConfig = { programs.starship.enable = true; };
					user = "kira";
					userConfig = { description = "Kira"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-prompts-starship-kira-vm" = vm.vm;
				apps."nixos-home-prompts-starship-kira-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-prompts-starship-kira-vm";
				};
			};
	}
]
