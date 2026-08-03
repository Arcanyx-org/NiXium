{ lib, self, inputs, ... }:

###! # Home Module for OpenSnitch UI
###!
###! Enables opensnitch-ui for all users when the OpenSnitch service is active.
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-service-opensnitch-ui-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.service-opensnitch-ui = ./user-service-opensnitch-ui.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-service-opensnitch-ui-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/modules/services/opensnitch-ui";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.service-opensnitch-ui ];
					homeManagerConfig = {
						# TODO(Krey): The module is gated on the system option
						# services.opensnitch.enable — enable it via systemConfig too.
					};
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-service-opensnitch-ui-vm" = vm.vm;
				apps."nixos-home-service-opensnitch-ui-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-service-opensnitch-ui-vm";
				};
			};
	}
]
