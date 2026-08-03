{ self, inputs, lib, ... }:

###! # Global Module for NVIDIA Security
###!
###! Patches critical vulnerabilities in the proprietary NVIDIA driver
###! (CVE-2024-0090..0099) by forcing a patched driver when the production
###! driver version is 535.154.  See `src/nixos/modules/security/nvidia/`.
###!
###! ## TEST ENVIRONMENT
###!
###! The interactive test VM is built with mkVM (`src/nixos/lib/mkVM`) and boots a
###! Wayland kiosk (greetd → cage → foot) with a bash shell, so the NVIDIA
###! security configuration can be inspected without touching real hardware.
###!
###! Usage:
###!   nix run .#nixos-security-nvidia-vm
###!
###! Inside the VM: inspect the resolved hardware.nvidia package.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.nixosModules.security-nvidia = ./security-nvidia.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "security-nvidia-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/modules/security/nvidia";
					graphical = "wayland";
					exitMode = "shell";
					timeout = null;
					networking = true;
					systemConfig = {
						# TODO(Krey): Adjust module-specific options for the test VM.
					};
				};
			in {
				packages."nixos-security-nvidia-vm" = vm.vm;
				apps."nixos-security-nvidia-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-security-nvidia-vm";
				};
			};
	}
]
