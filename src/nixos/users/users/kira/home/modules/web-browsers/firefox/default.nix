{ lib, self, ... }:

###! # Home Module for Firefox (kira)
###!
###! Kira's Firefox configuration (currently an empty shell — extensions and
###! policies live in the generic firefox module).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-web-browsers-firefox-kira-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.web-browsers-firefox-kira = ./firefox.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-web-browsers-firefox-kira-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kira/home/modules/web-browsers/firefox";
					graphical = "wayland";
					homeManagerModules = [
						self.homeManagerModules.web-browsers-firefox-kira
						# kira's home imports arkenfox for firefox profiles.
						self.inputs.arkenfox.hmModules.default
					];
					homeManagerConfig = {
						programs.firefox.enable = true;
						# mkVM forces home.stateVersion "25.11" (FIXME-UPSTREAM), so HM
						# warns about the programs.firefox.configPath legacy default.
						# Pin the legacy value to silence it.
						programs.firefox.configPath = ".mozilla/firefox";
					};
					user = "kira";
					userConfig = { description = "Kira"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-web-browsers-firefox-kira-vm" = vm.vm;
				apps."nixos-home-web-browsers-firefox-kira-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-web-browsers-firefox-kira-vm";
				};
			};
	}
]
