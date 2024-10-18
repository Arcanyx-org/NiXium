{ self, ... }:

# Flake management of MORPH system

{
	flake.nixosModules."nixos-morph" = {
		imports = [
			self.nixosModules.default # Load NiXium's Global configuration

			# Machines
			self.nixosModules.machine-morph
			# self.nixosModules.machine-mracek
			# self.nixosModules.machine-sinnenfreude
			# self.nixosModules.machine-tupac

			# Users
			self.nixosModules.users-kreyren
			self.homeManagerModules."kreyren@morph"

			# Files
			./config/bootloader.nix
			./config/disks.nix
			./config/firmware.nix
			./config/hardware-acceleration.nix
			./config/initrd.nix
			./config/kernel.nix
			./config/networking.nix
			# ./config/remote-unlock.nix
			./config/security.nix
			./config/setup.nix
			./config/sound.nix
			./config/vm-build.nix

			./services/binfmt.nix
			./services/distributedBuilds.nix
			./services/openssh.nix
			./services/sunshine
			./services/tor.nix
		];
	};

	imports = [
		./releases # Include releases
	];

	# Module export to other systems in the infrastructure
	flake.nixosModules.machine-morph = ./lib/morph-export.nix;
}
