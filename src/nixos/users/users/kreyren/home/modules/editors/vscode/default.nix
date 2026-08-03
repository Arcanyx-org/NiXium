{ lib, self, ... }:

###! # Home Module for VSCodium (kreyren)
###!
###! Kreyren's VSCodium configuration, release-gated:
###! - 24.11: programs.vscode with extensions
###! - 25.05/25.11: programs.vscode with profiles.default
###! - 26.05+: programs.vscodium
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-editors-vscode-kreyren-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.
###!
###! The module is gated on programs.vscodium.enable (26.05+), enabled here
###! via homeManagerConfig so the release-appropriate branch activates.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.editors-vscode-kreyren = ./vscode.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-editors-vscode-kreyren-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/editors/vscode";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.editors-vscode-kreyren ];
					homeManagerConfig = {
						# 26.05+ branch is gated on programs.vscodium.enable.
						programs.vscodium.enable = true;
					};
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-editors-vscode-kreyren-vm" = vm.vm;
				apps."nixos-home-editors-vscode-kreyren-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-editors-vscode-kreyren-vm";
				};
			};
	}
]
