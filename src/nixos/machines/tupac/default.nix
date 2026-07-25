{ self, inputs, lib, pkgs, ... }:

# Flake management of TUPAC system

{
	# FIXME(Krey): Sub-optimal — _derivationName is used because alias resolution via
	# derivation path comparison (nix eval + toplevel.outPath) fails when configs can't
	# evaluate their toplevel (missing paths, broken modules, etc.)
	flake.nixosConfigurations."nixos-tupac" = self.nixosConfigurations."nixos-tupac-stable" // { _derivationName = "nixos-tupac-stable"; };

	flake.nixosModules."nixos-tupac" = {
		imports = [
			self.nixosModules.default

			{
				networking.hostName = "tupac";

				# NOTE(Krey): Experimenting..
					time.timeZone = "Europe/Vienna"; # Set Timezone

				# Necessary Evil :(
					hardware.enableRedistributableFirmware = true;
					hardware.cpu.intel.updateMicrocode = true;

				nixpkgs.hostPlatform = "x86_64-linux";
			}

			# Users
			self.nixosModules.users-kreyren
			self.homeManagerModules."kreyren@tupac"
			#self.nixosModules.users-kira
			# self.homeManagerModules."kira@tupac"

			# Files
			./config/autoUpgrade.nix
			./config/bootloader.nix
			./config/disks.nix
			./config/firmware.nix
			./config/hardware-acceleration.nix
			./config/hardware.nix
			./config/initrd.nix
			./config/kernel.nix
			./config/networking.nix
			./config/nvidia.nix
			./config/plymouth.nix
			./config/power-management.nix
			./config/printing.nix
			./config/security.nix
			./config/sound.nix
			./config/thermals.nix
			./config/vm-build.nix

			./services/binfmt.nix
			./services/distributedBuilds.nix
			./services/openssh.nix
			./services/openwebui.nix
			./services/sunshine.nix
			./services/tor.nix
			./services/wivrn.nix
			./services/odoo.nix

			# Extras
			# self.nixosModules.infra-base48
		];
	};

	imports = [
		./releases # Include releases
	];

	flake.nixosModules.machine-tupac = ./lib/tupac-export.nix;
}
