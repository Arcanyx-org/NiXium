{ lib, self, ... }:

###! # Home Module for Firefox (kreyren)
###!
###! Kreyren's Firefox configuration with arkenfox policies and addons
###! (jump-cutter, dearrow, darkreader, libredirect, terms-of-service, etc.).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-web-browsers-firefox-kreyren-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.
###!
###! The module is gated on programs.firefox.enable, enabled here via
###! homeManagerConfig so it activates. The firefox-addons argument is
###! provided by the arkenfox hm module.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.web-browsers-firefox-kreyren = ./firefox.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-web-browsers-firefox-kreyren-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/web-browsers/firefox";
					graphical = "wayland";
					homeManagerModules = [
						self.homeManagerModules.web-browsers-firefox-kreyren
						# kreyren's home imports arkenfox for firefox profiles.
						self.inputs.arkenfox.hmModules.default
					];
					homeManagerConfig = {
						programs.firefox.enable = true;
						# mkVM forces home.stateVersion "25.11" (FIXME-UPSTREAM), so HM
						# warns about the programs.firefox.configPath legacy default.
						# Pin the legacy value to silence it.
						programs.firefox.configPath = ".mozilla/firefox";
					};
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-web-browsers-firefox-kreyren-vm" = vm.vm;
				apps."nixos-home-web-browsers-firefox-kreyren-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-web-browsers-firefox-kreyren-vm";
				};
			};
	}
]