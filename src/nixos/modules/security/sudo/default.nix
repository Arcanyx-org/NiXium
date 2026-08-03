{ self, inputs, lib, ... }:

###! # Global Module for sudo Security
###!
###! Disables the sudo lecture (Defaults !lecture) for both sudo and sudo-rs.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the sudo
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-security-sudo-vm
###!
###! Inside the VM: run `sudo -l` / check sudolecture behaviour.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.security-sudo = ./security-sudo.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "security-sudo-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/security/sudo";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Enable sudo / sudo-rs so the lecture config applies.
						# security.sudo.enable = true;
					};
				};
			in {
				packages."nixos-security-sudo-vm" = vm.vm;
				apps."nixos-security-sudo-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-security-sudo-vm";
				};
			};
	}
]
