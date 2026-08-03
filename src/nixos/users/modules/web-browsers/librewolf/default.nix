{ lib, self, inputs, ... }:

###! # Home Module for LibreWolf
###!
###! Hardened LibreWolf with privacy.resistFingerprinting, WebGL disabled,
###! tracking protection and DoH (network.trr.mode = 3).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-web-browsers-librewolf-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot
###! (set `command = "librewolf"` to launch librewolf directly).

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.web-browsers-librewolf = ./librewolf.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-web-browsers-librewolf-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/modules/web-browsers/librewolf";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.web-browsers-librewolf ];
					homeManagerConfig = { programs.librewolf.enable = true; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-web-browsers-librewolf-vm" = vm.vm;
				apps."nixos-home-web-browsers-librewolf-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-web-browsers-librewolf-vm";
				};
			};
	}
]
