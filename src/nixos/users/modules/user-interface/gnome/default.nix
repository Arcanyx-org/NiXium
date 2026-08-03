{ lib, self, inputs, ... }:

###! # Home Module for GNOME UI
###!
###! Global user management of GNOME: networking (manual proxy via dconf) and
###! package configuration (dconf-editor, pinentry-gnome), release-gated for
###! the `services.xserver.desktopManager.gnome` option rename.
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-ui-gnome-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.ui-gnome.imports = [
			./config/networking.nix
			./config/packages.nix
		];
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-ui-gnome-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/modules/user-interface/gnome";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.ui-gnome ];
					homeManagerConfig = {
						# TODO(Krey): The module is gated on the system option
						# services.desktopManager.gnome.enable — enable it via
						# systemConfig too.
					};
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-ui-gnome-vm" = vm.vm;
				apps."nixos-home-ui-gnome-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-ui-gnome-vm";
				};
			};
	}
]
