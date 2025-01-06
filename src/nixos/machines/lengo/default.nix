{ self, ... }:

# Flake management of LENGO system

{
	flake.nixosModules."nixos-lengo" = {
		imports = [
			self.nixosModules.default # Load NiXium's Global configuration

			# Users
			self.nixosModules.users-kreyren
			# self.homeManagerModules."kreyren@lengo"

			# Files
			./services/binfmt.nix
			./services/distributedBuilds.nix
			./services/openssh.nix
			./services/tor.nix

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
			./config/suspend-then-hibernate.nix
			./config/vm-build.nix
		];
	};

	imports = [
		./releases # Include system releases
	];

	# Module export to other systems in the infrastructure
	flake.nixosModules.machine-ignucius = ./lib/lengo-export.nix;
}
