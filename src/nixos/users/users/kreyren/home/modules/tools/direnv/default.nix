{ lib, self, ... }:

###! # Home Module for direnv (kreyren)
###!
###! Kreyren's direnv setup with nix-direnv and bash integration, persisting
###! .local/share/direnv on impermanence.
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-tools-direnv-kreyren-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.tools-direnv-kreyren = ./direnv.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-tools-direnv-kreyren-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/tools/direnv";
					graphical = "wayland";
					homeManagerModules = [
						self.homeManagerModules.tools-direnv-kreyren
						# Module references config.home.impermanence.enable —
						# vendored impermanence HM module declares that option.
						self.inputs.impermanence.nixosModules.home-manager.impermanence
					];
					homeManagerConfig = {
						home.impermanence.enable = true;
					};
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-tools-direnv-kreyren-vm" = vm.vm;
				apps."nixos-home-tools-direnv-kreyren-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-tools-direnv-kreyren-vm";
				};
			};
	}
]
