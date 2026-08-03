{ self, inputs, lib, ... }:

###! # Global Module for Base48 Infrastructure
###!
###! Base48 Hackerspace infrastructure exposing privileged access to the
###! infrastructure: Tor onion services (website, Home Assistant, FDM printers,
###! paper printer), client authorization, CUPS printer setup and avahi mDNS.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the Base48
###! infrastructure config can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-infra-base48-vm
###!
###! Inside the VM: inspect tor/age/cups configuration.  NOTE: age secrets and
###! tor must be configured/enabled before the module is fully functional.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.infra-base48 = ./infra-base48.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "infra-base48-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/infra/base48";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Enable tor + secrets needed by the module.
					};
				};
			in {
				packages."nixos-infra-base48-vm" = vm.vm;
				apps."nixos-infra-base48-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-infra-base48-vm";
				};
			};
	}
]
