{ self, inputs, lib, ... }:

###! # Global Module for SSHD
###!
###! Hardens OpenSSH: pubkey-only authentication, no firewall auto-open,
###! post-quantum KexAlgorithms (NTRU Prime) and no keyboard-interactive auth.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell.  mkVM already enables
###! OpenSSH, so the sshd hardening is exercised automatically.
###!
###! Usage:
###!   nix run .#nixos-services-sshd-vm
###!
###! Inside the VM: check `sshd -T` for the hardened settings.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.services-sshd = ./services-sshd.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "services-sshd-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/services/sshd";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Adjust module-specific options for the test VM.
					};
				};
			in {
				packages."nixos-services-sshd-vm" = vm.vm;
				apps."nixos-services-sshd-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-services-sshd-vm";
				};
			};
	}
]
