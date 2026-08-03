{ self, inputs, lib, ... }:

###! # Global Module for Tor
###!
###! Configures tor as a relay by default, adds SOCKS5 SSH ProxyCommand for
###! *.onion/*.nx hosts, client authorization and impermanence persistence of
###! the tor data directory.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the tor
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-services-tor-vm
###!
###! Inside the VM: check tor configuration and SSH ProxyCommand.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.services-tor = ./services-tor.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "services-tor-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/services/tor";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Enable services.tor so the module applies.
						# services.tor.enable = true;
					};
				};
			in {
				packages."nixos-services-tor-vm" = vm.vm;
				apps."nixos-services-tor-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-services-tor-vm";
				};
			};
	}
]
