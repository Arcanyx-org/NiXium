{ self, inputs, lib, pkgs, ... }:

# Flake management of SCAR system

{
	# FIXME(Krey): Sub-optimal — _derivationName is used because alias resolution via
	# derivation path comparison (nix eval + toplevel.outPath) fails when configs can't
	# evaluate their toplevel (missing paths, broken modules, etc.)
	flake.nixosConfigurations."nixos-scar" = self.nixosConfigurations."nixos-scar-stable" // { _derivationName = "nixos-scar-stable"; };

	flake.nixosModules."nixos-scar" = {
		imports = [
			self.nixosModules.default

			{
				networking.hostName = "scar";

				# NOTE(Krey): Experimenting..
					time.timeZone = "Europe/Vienna"; # Set Timezone

				# Necessary Evil :(
					hardware.enableRedistributableFirmware = true;
					hardware.cpu.intel.updateMicrocode = true;

				nixpkgs.hostPlatform = "x86_64-linux";
			}

			# Users
			self.nixosModules.users-kreyren
			# self.homeManagerModules."kreyren@scar"
			self.nixosModules.users-kira
			# self.homeManagerModules."kira@scar"

			# Files
			./config/autoUpgrade.nix
			./config/bootloader.nix
			./config/disks.nix
			./config/firmware.nix
			./config/hardware-acceleration.nix
			./config/hardware.nix
			./config/initrd.nix
			./config/input.nix
			./config/kernel.nix
			./config/networking.nix
			./config/nvidia.nix
			./config/plymouth.nix
			./config/printing.nix
			./config/security.nix
			./config/sound.nix

			./services/binfmt.nix
			./services/openssh.nix
			./services/sunshine.nix
			./services/tor.nix

			# Extras
			# self.nixosModules.infra-base48
		];
	};

	imports = [
		./releases # Include releases
	];

	flake.nixosModules.machine-scar = ./lib/scar-export.nix;
}
