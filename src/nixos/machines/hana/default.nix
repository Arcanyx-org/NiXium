{ self, mobile-nixos-hana, ... }:

# Flake management of HANA system

{
	flake.nixosModules."nixos-hana" = {
		imports = [
			self.nixosModules.default # Load NiXium's Global configuration

			(import "${mobile-nixos-hana}/lib/configuration.nix" { device = "lenovo-hana"; }) # Import NixOS-Mobile config

			# Users
			self.nixosModules.users-kreyren
			# self.homeManagerModules."kreyren@hana"

			# Files
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
			./config/suspend-then-hibernate.nix
			./config/thinkfan.nix
			./config/usbguard.nix
			./config/vm-build.nix

			./services/binfmt.nix
			./services/openssh.nix
			./services/tor.nix
		];
	};

	imports = [
		./releases # Include system releases
	];

	# Module export to other systems in the infrastructure
	flake.nixosModules.machine-ignucius = ./lib/ignucius-export.nix;
}
