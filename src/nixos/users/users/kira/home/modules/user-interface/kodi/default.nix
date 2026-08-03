{ lib, self, ... }:

###! # Home Module for Kodi (kira)
###!
###! Kira's Kodi configuration (package management, release-gated).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-ui-kodi-kira-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.
###! The kodi desktop gating (services.xserver.desktopManager.kodi.enable) is
###! not enabled in the VM — the module body evaluates but is mostly inert.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in {
	config = mkMerge [
		{
			flake.homeManagerModules.ui-kodi-kira.imports = [
				./config/packages.nix
				./kodi.nix
			];
		}

		{
			perSystem = { system, pkgs, ... }:
				let
					vm = mkVM {
						inherit pkgs system;
						name = "home-ui-kodi-kira-vm";
						command = "bash";
						modulePath = "$FLAKE_ROOT/src/nixos/users/users/kira/home/modules/user-interface/kodi";
						graphical = "wayland";
						homeManagerModules = [ self.homeManagerModules.ui-kodi-kira ];
						homeManagerConfig = { };
						user = "kira";
						userConfig = { description = "Kira"; };
						exitMode = "shell";
						timeout = null;
						networking = true;
					};
				in {
					packages."nixos-home-ui-kodi-kira-vm" = vm.vm;
					apps."nixos-home-ui-kodi-kira-vm" = {
						type = "app";
						program = "${vm.runner}/bin/nixos-home-ui-kodi-kira-vm";
					};
				};
		}
	];
}
