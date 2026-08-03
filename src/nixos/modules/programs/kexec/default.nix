{ self, inputs, lib, ... }:

###! # Global Module for kexec
###!
###! Kernel live-patching support — provides kexec-tools for the system-level
###! `kexec` administration task.  Allows switching kernels without firmware
###! re-initialization (preserves LUKS).
###!
###! NOTE: The full kexec task is NOT implemented yet (deferred) — see
###! `tasks/administration/kexec/tasks-kexec.sh`.  This module only installs
###! the kexec-tools package.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so kexec-tools can be
###! inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-programs-kexec-vm
###!
###! Inside the VM: run `kexec --version`.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.programs-kexec = ./programs-kexec.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "programs-kexec-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/programs/kexec";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						environment.systemPackages = [ pkgs.kexec-tools ];
					};
				};
			in {
				packages."nixos-programs-kexec-vm" = vm.vm;
				apps."nixos-programs-kexec-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-programs-kexec-vm";
				};
			};
	}
]
