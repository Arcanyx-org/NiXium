{ self, inputs, lib, ... }:

###! # Global Module for CCache
###!
###! Exposes the ccache cacheDir to the nix sandbox and persists it when
###! impermanence is enabled.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the ccache
###! configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-system-ccache-vm
###!
###! Inside the VM: check the nix sandbox paths include the ccache dir.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.system-ccache = ./system-ccache.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "system-ccache-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/system/ccache";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Enable programs.ccache so the module applies.
						# programs.ccache.enable = true;
					};
				};
			in {
				packages."nixos-system-ccache-vm" = vm.vm;
				apps."nixos-system-ccache-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-system-ccache-vm";
				};
			};
	}
]
