{ self, ... }:

# Flake management of IGNUCIUS system

{
	flake.nixosModules."nixos-ignucius" = {
		imports = [
			self.nixosModules.default # Load NiXium's Global configuration

			# Users
			self.nixosModules.users-kreyren
			self.homeManagerModules."kreyren@ignucius"

			# Files
			./services/binfmt.nix
			# ./services/distributedBuilds.nix
			./services/openssh.nix
			./services/tor.nix

			./config/bootloader.nix
			./config/disks.nix
			./config/firmware.nix
			./config/hardware-acceleration.nix
			./config/initrd.nix
			./config/kernel.nix
			./config/networking.nix
			./config/security.nix
			./config/setup.nix
			./config/sound.nix
			./config/vm-build.nix
		];
	};

	imports = [
		./releases # Include system releases
	];

	# Module export to other systems in the infrastructure
	flake.nixosModules.machine-ignucius = ./lib/ignucius-export.nix;
}
