{ lib, self, inputs, ... }:

###! # Vim Editor Configuration for Kreyren
###!
###! This module provides:
###! 1. A home-manager module (vim.nix) for Kreyren's vim configuration
###! 2. A VM test environment for validating vim changes without bare-metal deployment
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###! - vim: The editor being tested
###!
###! Usage:
###!   nix run .#nixos-home-editors-vim-kreyren-vm
###!
###! The VM will boot directly into vim via: greetd -> cage -> foot -e vim

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.editors-vim-kreyren = ./vim.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-editors-vim-kreyren-vm";
					command = "vim";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/editors/vim";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.editors-vim-kreyren ];
					homeManagerConfig = { programs.vim.enable = true; };
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
				};
			in {
				packages."nixos-home-editors-vim-kreyren-vm" = vm.vm;
				apps."nixos-home-editors-vim-kreyren-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-editors-vim-kreyren-vm";
				};
			};
	}
]
