{ lib, self, ... }:

###! # Home Module for Flatpak (kreyren)
###!
###! Kreyren's Flatpak configuration (currently an empty shell).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-system-flatpak-kreyren-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.system-flatpak-kreyren = ./flatpak.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-system-flatpak-kreyren-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/system/flatpak";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.system-flatpak-kreyren ];
					homeManagerConfig = { };
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-system-flatpak-kreyren-vm" = vm.vm;
				apps."nixos-home-system-flatpak-kreyren-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-system-flatpak-kreyren-vm";
				};
			};
	}
]
