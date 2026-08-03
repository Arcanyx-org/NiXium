{ lib, self, ... }:

###! # Home Module for Kodi (kreyren)
###!
###! Kreyren's Kodi configuration (package management, release-gated).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-ui-kodi-kreyren-vm
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
			flake.homeManagerModules.ui-kodi-kreyren.imports = [
				./config/packages.nix
				./kodi.nix
			];
		}

		{
			perSystem = { system, pkgs, ... }:
				let
					vm = mkVM {
						inherit pkgs system;
						name = "home-ui-kodi-kreyren-vm";
						command = "bash";
						modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/user-interface/kodi";
						graphical = "wayland";
						homeManagerModules = [ self.homeManagerModules.ui-kodi-kreyren ];
						homeManagerConfig = { };
						user = "kreyren";
						userConfig = { description = "Kreyren"; };
						exitMode = "shell";
						timeout = null;
						networking = true;
					};
				in {
					packages."nixos-home-ui-kodi-kreyren-vm" = vm.vm;
					apps."nixos-home-ui-kodi-kreyren-vm" = {
						type = "app";
						program = "${vm.runner}/bin/nixos-home-ui-kodi-kreyren-vm";
					};
				};
		}
	];
}
