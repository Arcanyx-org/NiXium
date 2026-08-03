{ self, inputs, lib, ... }:

###! # Global Module for ACME (HTTPS Certificates)
###!
###! Infrastructure-wide management of HTTPS certificates via ACME:
###! accepts terms and sets the default certificate email.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the ACME
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-security-acme-vm
###!
###! Inside the VM: inspect the generated ACME configuration.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.security-acme = ./security-acme.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "security-acme-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/security/acme";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Adjust module-specific options for the test VM.
					};
				};
			in {
				packages."nixos-security-acme-vm" = vm.vm;
				apps."nixos-security-acme-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-security-acme-vm";
				};
			};
	}
]
