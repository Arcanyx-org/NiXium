{ self, inputs, ... }:

# Flake management of SINNENFREUDE system

# FIXME-SECURITY(Krey): To Be Managed..
# ⚠️ Mount point '/boot' which backs the random seed file is world accessible, which is a security hole! ⚠️
# ⚠️ Random seed file '/boot/loader/.#bootctlrandom-seed048bca5ff68f0657' is world accessible, which is a security hole! ⚠️

{
	flake.nixosModules."nixos-sinnenfreude" = {
		imports = [
			self.nixosModules.default

			# Users
			self.nixosModules.users-kreyren
			self.homeManagerModules."kreyren@sinnenfreude"

			# Files
			./config/bootloader.nix
			./config/disks.nix
			./config/firmware.nix
			./config/hardware-acceleration.nix
			./config/initrd.nix
			./config/kernel.nix
			./config/networking.nix
			./config/nvidia.nix
			./config/security.nix
			./config/setup.nix
			./config/suspend-then-hibernate.nix
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

	# Export to other systems
	flake.nixosModules.machine-sinnenfreude = ./lib/sinnenfreude-export.nix;
}
