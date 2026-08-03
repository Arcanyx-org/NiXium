{ self, inputs, lib, ... }:

###! # Global Module for Firewall
###!
###! Always enables the firewall by default and denies pings.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the firewall
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-system-firewall-vm
###!
###! Inside the VM: check firewall status (nftables/iptables) and ping policy.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.system-firewall = ./system-firewall.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "system-firewall-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/system/firewall";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Adjust module-specific options for the test VM.
					};
				};
			in {
				packages."nixos-system-firewall-vm" = vm.vm;
				apps."nixos-system-firewall-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-system-firewall-vm";
				};
			};
	}
]
