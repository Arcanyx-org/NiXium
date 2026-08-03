{ lib, self, inputs, ... }:

###! # Home Module for AppImage
###!
###! Makes appimage-run the default handler for AppImage files
###! (application/vnd.appimage and related MIME types).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-programs-appimage-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.programs-appimage = ./appimage-home.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-programs-appimage-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/modules/programs/appimage";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.programs-appimage ];
					homeManagerConfig = {
						# TODO(Krey): The module is gated on the system option
						# programs.appimage.enable — enable it via systemConfig too.
					};
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-programs-appimage-vm" = vm.vm;
				apps."nixos-home-programs-appimage-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-programs-appimage-vm";
				};
			};
	}
]
