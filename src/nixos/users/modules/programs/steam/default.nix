{ lib, self, inputs, ... }:

###! # Home Module for Steam
###!
###! Persists the whole Steam tree when user impermanence is enabled, so install
###! identity and auth state survive reboot on tmpfs home.
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-programs-steam-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.programs-steam = ./steam.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-programs-steam-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/modules/programs/steam";
					graphical = "wayland";
					homeManagerModules = [
						self.homeManagerModules.programs-steam
						# Module references config.home.impermanence.enable —
						# vendored impermanence HM module declares that option.
						self.inputs.impermanence.nixosModules.home-manager.impermanence
					];
					homeManagerConfig = {
						# TODO(Krey): The module is gated on the system option
						# programs.steam.enable — enable it via systemConfig too.
					};
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-programs-steam-vm" = vm.vm;
				apps."nixos-home-programs-steam-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-programs-steam-vm";
				};
			};
	}
]
