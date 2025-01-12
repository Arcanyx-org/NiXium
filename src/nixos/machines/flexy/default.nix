{ self, config, ... }:

# Flake management of FLEXY system

let
	inherit (config.flake) nixosModules;
in {
	flake.nixosModules."nixos-flexy" = {
		imports = [
			self.nixosModules.default # Load NiXium's Global configuration

			# Users
			self.nixosModules.users-kreyren
			self.homeManagerModules."kreyren@flexy"
			# self.nixosModules.users-kira
			# self.homeManagerModules."kira@flexy"

			# Files
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

			./services/binfmt.nix
			./services/distributedBuilds.nix
			./services/openssh.nix
			./services/tor.nix

			nixosModules.machine-ignucius
			nixosModules.machine-morph
			nixosModules.machine-mracek
			nixosModules.machine-sinnenfreude
			# nixosModules.machine-tupac
		];
	};

	imports = [
		./releases # Include system releases
	];

	# Module export to other systems in the infrastructure
	flake.nixosModules.machine-flexy = ./lib/flexy-export.nix;
}
