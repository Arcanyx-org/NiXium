{ lib, self, ... }:

###! # Home Module for Git (kreyren)
###!
###! Kreyren's Git configuration (identity, signing, delta), release-gated
###! for the programs.git.userName -> settings.user rename on 25.11+.
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-tools-git-kreyren-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.
###!
###! The module is gated on programs.git.enable, enabled here via
###! homeManagerConfig so the release-appropriate branch activates.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.tools-git-kreyren = ./git.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-tools-git-kreyren-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/tools/git";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.tools-git-kreyren ];
					homeManagerConfig = {
						programs.git.enable = true;
					};
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-tools-git-kreyren-vm" = vm.vm;
				apps."nixos-home-tools-git-kreyren-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-tools-git-kreyren-vm";
				};
			};
	}
]
