{ lib, self, ... }:

###! # Home Module for GTK (kreyren)
###!
###! Kreyren's GTK theme configuration (Adw-gtk3-dark, dark preference).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-system-gtk-kreyren-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.system-gtk-kreyren = ./gtk.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-system-gtk-kreyren-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/system/gtk";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.system-gtk-kreyren ];
					homeManagerConfig = { };
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-system-gtk-kreyren-vm" = vm.vm;
				apps."nixos-home-system-gtk-kreyren-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-system-gtk-kreyren-vm";
				};
			};
	}
]
