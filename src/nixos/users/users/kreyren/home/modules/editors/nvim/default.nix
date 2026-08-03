{ lib, self, ... }:

###! # Neovim Editor Configuration for Kreyren
###!
###! This module provides:
###! 1. A home-manager module (nvim.nix) for Kreyren's neovim configuration
###! 2. A minimal VM test environment for validating nvim changes
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor
###! - foot: Lightweight Wayland terminal
###! - nvim: The editor being tested
###!
###! Usage:
###!   nix run .#nixos-home-editors-nvim-kreyren-vm

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.editors-nvim-kreyren = ./nvim.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-editors-nvim-kreyren-vm";
					command = "nvim";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/editors/nvim";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.editors-nvim-kreyren ];
					homeManagerConfig = { programs.neovim.enable = true; };
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
				};
			in {
				packages."nixos-home-editors-nvim-kreyren-vm" = vm.vm;
				apps."nixos-home-editors-nvim-kreyren-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-editors-nvim-kreyren-vm";
				};
			};
	}
]
