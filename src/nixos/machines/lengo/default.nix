{ self, ... }:

# Flake management of LENGO system

{
	# FIXME(Krey): Sub-optimal — _derivationName is used because alias resolution via
	# derivation path comparison (nix eval + toplevel.outPath) fails when configs can't
	# evaluate their toplevel (missing paths, broken modules, etc.)
	flake.nixosConfigurations."nixos-lengo" = self.nixosConfigurations."nixos-lengo-stable" // { _derivationName = "nixos-lengo-stable"; };

	flake.nixosModules."nixos-lengo" = {
		imports = [
			self.nixosModules.default # Load NiXium's Global configuration

			# Users
			self.nixosModules.users-kreyren
				self.homeManagerModules."kreyren@lengo"
			self.nixosModules.users-kira
				self.homeManagerModules."kira@lengo"

			# Files
			./services/binfmt.nix
			./services/distributedBuilds.nix
			./services/openssh.nix
			./services/sunshine.nix
			./services/tor.nix

			./config/bootloader.nix
			./config/disks.nix
			./config/firmware.nix
			./config/hardware-acceleration.nix
			./config/hardware.nix
			./config/initrd.nix
			# ./config/jovian.nix
			./config/kernel.nix
			./config/networking.nix
			./config/plymouth.nix
			./config/power-management.nix
			./config/security.nix
			./config/setup.nix
			./config/sound.nix
			./config/suspend-then-hibernate.nix
			./config/unl0kr.nix
			./config/vm-build.nix
		];
	};

	imports = [
		./releases # Include system releases
	];

	# Module export to other systems in the infrastructure
	flake.nixosModules.machine-lengo = ./lib/lengo-export.nix;
}
