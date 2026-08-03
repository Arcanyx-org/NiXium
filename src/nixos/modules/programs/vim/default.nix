{ self, inputs, lib, ... }:

###! # Global Module for vim
###!
###! System-wide vim configuration — installs vim on all systems.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so vim can be
###! inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-programs-vim-vm
###!
###! Inside the VM: run `vim`.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.programs-vim = ./programs-vim.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "programs-vim-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/programs/vim";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						environment.systemPackages = [ pkgs.vim ];
					};
				};
			in {
				packages."nixos-programs-vim-vm" = vm.vm;
				apps."nixos-programs-vim-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-programs-vim-vm";
				};
			};
	}
]
