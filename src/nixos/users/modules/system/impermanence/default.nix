{ lib, self, inputs, ... }:

###! # Home Module for User Impermanence
###!
###! Declares the user persistence store: XDG dirs, config, ssh/gnupg keys,
###! HM profiles and app data, with stripHomePrefix enabled.
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-system-impermanence-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.system-impermanence = ./impermanence.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-system-impermanence-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/modules/system/impermanence";
					graphical = "wayland";
					homeManagerModules = [
						self.homeManagerModules.system-impermanence
						# Module references config.home.impermanence.enable —
						# vendored impermanence HM module declares that option.
						self.inputs.impermanence.nixosModules.home-manager.impermanence
					];
					homeManagerConfig = {
						# TODO(Krey): The module is gated on home.impermanence.enable
						# — enable it via homeManagerConfig too.
					};
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-system-impermanence-vm" = vm.vm;
				apps."nixos-home-system-impermanence-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-system-impermanence-vm";
				};
			};
	}
]
