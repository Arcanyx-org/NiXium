{ self, ... }:

# Flake management of IGNUCIUS system

{
	# FIXME(Krey): Sub-optimal — _derivationName is used because alias resolution via
	# derivation path comparison (nix eval + toplevel.outPath) fails when configs can't
	# evaluate their toplevel (missing paths, broken modules, etc.)
	flake.nixosConfigurations."nixos-ignucius" = self.nixosConfigurations."nixos-ignucius-24_05" // { _derivationName = "nixos-ignucius-24_05"; };

	flake.nixosModules."nixos-ignucius" = {
		imports = [
			self.nixosModules.default # Load NiXium's Global configuration

			# Users
			self.nixosModules.users-kreyren
			self.homeManagerModules."kreyren@ignucius"

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
			./config/thinkfan.nix
			./config/usbguard.nix
			./config/vm-build.nix
		];
	};

	imports = [
		./releases # Include system releases
	];

	# Module export to other systems in the infrastructure
	flake.nixosModules.machine-ignucius = ./lib/ignucius-export.nix;
}
