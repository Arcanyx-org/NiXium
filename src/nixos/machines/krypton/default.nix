{ self, ... }:

# Flake management of KRYPTON system

{
	flake.nixosModules."nixos-krypton" = {
		imports = [
			self.nixosModules.default # Load NiXium's Global configuration

			# Users
			self.nixosModules.users-kreyren
			# self.homeManagerModules."kreyren@krypton"

			(import "${self.inputs.mobile-nixos}/lib/configuration.nix" { device = "furilabs-krypton"; })

			# Files
			./config/bootloader.nix
			./config/firmware.nix
			./config/hardware-acceleration.nix
			./config/initrd.nix
			./config/kernel.nix
			./config/networking.nix
			./config/plymouth.nix
			./config/security.nix
			./config/setup.nix
			./config/sound.nix
			./config/vm-build.nix

			./services/binfmt.nix
			./services/distributedBuilds.nix
			./services/openssh.nix
			./services/tor.nix
		];
	};

	imports = [
		./releases # Include system releases
	];

	# Module export to other systems in the infrastructure
	flake.nixosModules.machine-ignucius = ./lib/krypton-export.nix;
}
