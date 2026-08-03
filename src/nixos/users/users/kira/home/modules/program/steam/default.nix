{ lib, self, ... }:

###! # Home Module for Steam (kira)
###!
###! Persists the Steam tree for user kira when impermanence is enabled, so
###! install identity and auth state survive reboot on tmpfs home.
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Unlike the generic steam VM (which boots to an inert shell because the
###! module is gated on the system option programs.steam.enable), this VM
###! ENABLES programs.steam.enable via systemConfig so kira's persistence
###! logic actually activates and is testable.
###!
###! Usage:
###!   nix run .#nixos-home-program-steam-kira-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.program-steam-kira = ./steam.nix;
	}

	{
		perSystem = { system, ... }:
			let
				# programs.steam.enable requires unfree packages.
				pkgs = import self.inputs.nixpkgs {
					inherit system;
					config.allowUnfree = true;
				};

				vm = mkVM {
					inherit pkgs system;
					name = "home-program-steam-kira-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kira/home/modules/program/steam";
					graphical = "wayland";
					# Activate kira's steam.nix — it's gated on this system option.
					systemConfig = {
						programs.steam.enable = true;
					};
					homeManagerModules = [
						self.homeManagerModules.program-steam-kira
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
				packages."nixos-home-program-steam-kira-vm" = vm.vm;
				apps."nixos-home-program-steam-kira-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-program-steam-kira-vm";
				};
			};
	}
]
