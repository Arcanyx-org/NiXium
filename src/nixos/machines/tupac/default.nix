{ self, inputs, ... }:

# Flake management of TUPAC system

{
	flake.nixosModules."nixos-tupac" = {
		imports = [
			self.nixosModules.default

			# Users
			self.nixosModules.users-kreyren
			self.homeManagerModules."kreyren@tupac"
			# self.nixosModules.users-kira
			# self.homeManagerModules."kira@tupac"

			# Files
			./config/autoUpgrade.nix
			./config/bootloader.nix
			./config/disks.nix
			./config/firmware.nix
			./config/hardware-acceleration.nix
			./config/initrd.nix
			./config/kernel.nix
			./config/networking.nix
			./config/nvidia.nix
			./config/plymouth.nix
			./config/power-management.nix
			./config/printing.nix
			./config/security.nix
			./config/setup.nix
			./config/sound.nix
			./config/suspend-then-hibernate.nix
			./config/vm-build.nix

			./services/binfmt.nix
			./services/distributedBuilds.nix
			./services/openssh.nix
			./services/openwebui.nix
			./services/tor.nix
			./services/wivrn.nix
		];
	};

	imports = [
		./releases # Include releases
	];

	flake.nixosModules.machine-tupac = ./lib/tupac-export.nix;
}
