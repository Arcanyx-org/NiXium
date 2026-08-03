{ lib, self, inputs, ... }:

###! # Home Module for Firefox
###!
###! Hardened Firefox with enterprise policies (purity enforcement, tracking
###! protection, arkenfox profiles, extension management via declarative
###! install_url, SearXNG search, Tor SOCKS proxy).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-web-browsers-firefox-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot
###! (set `command = "firefox"` to launch firefox directly).

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.web-browsers-firefox = ./firefox.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-web-browsers-firefox-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/modules/web-browsers/firefox";
					graphical = "wayland";
					homeManagerModules = [
						self.homeManagerModules.web-browsers-firefox
						# Module uses programs.firefox.arkenfox — declared by the arkenfox HM module.
						self.inputs.arkenfox.hmModules.default
					];
					homeManagerConfig = {
						programs.firefox.enable = true;
						# mkVM forces home.stateVersion "25.11" (FIXME-UPSTREAM), so HM
						# warns about the programs.firefox.configPath legacy default.
						# Pin the legacy value to silence it.
						programs.firefox.configPath = ".mozilla/firefox";
					};
					extraSpecialArgs = {
						firefox-addons = self.inputs.firefox-addons.packages."${system}";
						nixpkgs-24_05 = self.inputs.nixpkgs-24_05.legacyPackages."${system}";
					};
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-web-browsers-firefox-vm" = vm.vm;
				apps."nixos-home-web-browsers-firefox-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-web-browsers-firefox-vm";
				};
			};
	}
]
