{ self, ... }:

# Flake management of TWINKCENTRAL system

{
	flake.nixosModules."nixos-twinkcentral" = {
		imports = [
			self.nixosModules.default # Load NiXium's Global configuration

			# Users
			# self.nixosModules.users-kreyren
			# self.homeManagerModules."kreyren@twinkcentral"

			# Files
			./services/binfmt.nix
			./services/distributedBuilds.nix
			./services/openssh.nix
			./services/tor.nix

			./config/autoUpgrade.nix
			./config/bootloader.nix
			./config/disks.nix
			./config/firmware.nix
			./config/hardware-acceleration.nix
			./config/initrd.nix
			./config/kernel.nix
			./config/networking.nix
			./config/plymouth.nix
			./config/power-management.nix
			./config/security.nix
			./config/setup.nix
			./config/sound.nix
			./config/usbguard.nix
			./config/vm-build.nix
		];
	};

	imports = [
		./releases # Include system releases
	];

	# Module export to other systems in the infrastructure
	flake.nixosModules.machine-twinkcentral = ./lib/twinkcentral-export.nix;
}
