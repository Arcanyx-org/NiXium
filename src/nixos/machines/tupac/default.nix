{ self, inputs, ... }:

# Flake management of TUPAC system

# FIXME-SECURITY(Krey): To Be Managed..
# ⚠️ Mount point '/boot' which backs the random seed file is world accessible, which is a security hole! ⚠️
# ⚠️ Random seed file '/boot/loader/.#bootctlrandom-seed048bca5ff68f0657' is world accessible, which is a security hole! ⚠️

{
	flake.nixosModules."nixos-tupac" = {
		imports = [
			self.nixosModules.default

			# Users
			self.nixosModules.users-kreyren
			self.homeManagerModules."kreyren@tupac"
			self.nixosModules.users-kira
			self.homeManagerModules."kira@tupac"

			# Files
			./config/bootloader.nix
			./config/disks.nix
			./config/firmware.nix
			./config/hardware-acceleration.nix
			./config/initrd.nix
			./config/kernel.nix
			./config/networking.nix
			./config/nvidia.nix
			./config/power-management.nix
			./config/printing.nix
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
		./releases # Include releases
	];

	flake.nixosModules.machine-tupac = ./lib/tupac-export.nix;
}
