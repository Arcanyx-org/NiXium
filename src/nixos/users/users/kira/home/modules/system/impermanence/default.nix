{ lib, self, ... }:

###! # Home Module for User Impermanence (kira)
###!
###! Declares kira's user persistence store (currently an empty shell — the
###! actual persistence entries live in the per-app modules, e.g. steam).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-system-impermanence-kira-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.system-impermanence-kira = ./impermanence.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-system-impermanence-kira-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kira/home/modules/system/impermanence";
					graphical = "wayland";
					homeManagerModules = [
						self.homeManagerModules.system-impermanence-kira
						# Module references config.home.impermanence.enable —
						# vendored impermanence HM module declares that option.
						self.inputs.impermanence.nixosModules.home-manager.impermanence
					];
					homeManagerConfig = {
						home.impermanence.enable = true;
					};
					user = "kira";
					userConfig = { description = "Kira"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-system-impermanence-kira-vm" = vm.vm;
				apps."nixos-home-system-impermanence-kira-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-system-impermanence-kira-vm";
				};
			};
	}
]
