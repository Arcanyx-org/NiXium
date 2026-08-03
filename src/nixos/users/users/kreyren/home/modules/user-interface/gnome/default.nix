{ lib, self, ... }:

###! # Home Module for GNOME UI (kreyren)
###!
###! Kreyren's GNOME configuration: input, night-light filter, shortcuts,
###! touchpad, usability, weather, plus the theme modules.
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-ui-gnome-kreyren-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in {
	imports = [
		./themes
	];

	config = mkMerge [
		{
			flake.homeManagerModules.ui-gnome-kreyren.imports = [
				./config/input.nix
				./config/nightlight-filter.nix
				./config/shortcuts.nix
				./config/touchpad.nix
				./config/usability.nix
				./config/weather.nix
			];
		}

		{
			perSystem = { system, pkgs, ... }:
				let
					vm = mkVM {
						inherit pkgs system;
						name = "home-ui-gnome-kreyren-vm";
						command = "bash";
						modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/user-interface/gnome";
						graphical = "wayland";
						homeManagerModules = [ self.homeManagerModules.ui-gnome-kreyren ];
						homeManagerConfig = { };
						user = "kreyren";
						userConfig = { description = "Kreyren"; };
						exitMode = "shell";
						timeout = null;
						networking = true;
					};
				in {
					packages."nixos-home-ui-gnome-kreyren-vm" = vm.vm;
					apps."nixos-home-ui-gnome-kreyren-vm" = {
						type = "app";
						program = "${vm.runner}/bin/nixos-home-ui-gnome-kreyren-vm";
					};
				};
		}
	];
}
