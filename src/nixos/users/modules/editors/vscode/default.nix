{ lib, self, inputs, ... }:

###! # Home Module for VSCode/VSCodium
###!
###! VSCodium (telemetry-free) with default extensions (editorconfig, direnv,
###! nix-ide, indent-rainbow) and purity enforcement (no auto-update checks).
###! Release-gated for `programs.vscode` option changes across releases.
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-editors-vscode-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot
###! (set `command = "code"` to launch VSCodium directly).

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.editors-vscode = ./vscode.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-editors-vscode-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/modules/editors/vscode";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.editors-vscode ];
					homeManagerConfig = {
						# TODO(Krey): Module vscode.nix's 26.05 branch sets
						# programs.vscode.package = pkgs.vscodium, which triggers an
						# HM warning ("use programs.vscodium instead") that aborts
						# eval under abort-on-warn. Migrate the 26.05 branch to
						# programs.vscodium, then flip the enable below back on.
						# programs.vscode.enable = true;
					};
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-editors-vscode-vm" = vm.vm;
				apps."nixos-home-editors-vscode-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-editors-vscode-vm";
				};
			};
	}
]
