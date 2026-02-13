{ self, inputs, ... }:

# Flake management of SINNENFREUDE system

{
	flake.nixosModules."nixos-sinnenfreude" = {
		imports = [
			self.nixosModules.default

			{
				networking.hostName = "sinnenfreude";

				# NOTE(Krey): Experimenting..
					time.timeZone = "Europe/Vienna"; # Set Timezone

				# Necessary Evil :(
					hardware.enableRedistributableFirmware = true;
					hardware.cpu.intel.updateMicrocode = true;

				nixpkgs.hostPlatform = "x86_64-linux";
			}

			# Users
			self.nixosModules.users-kreyren
			self.homeManagerModules."kreyren@sinnenfreude"

			self.nixosModules.users-kira
			self.homeManagerModules."kira@sinnenfreude"

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
			./config/security.nix
			./config/vm-build.nix

			./services/binfmt.nix
			./services/distributedBuilds.nix
			./services/openssh.nix
			./services/tor.nix

			# Systems
				# self.nixosModules.machine-ignucius
				self.nixosModules.machine-lengo
				self.nixosModules.machine-mracek
				self.nixosModules.machine-sinnenfreude
				# self.nixosModules.machine-tupac
				self.nixosModules.machine-twinkcentral

			# Extras
			self.nixosModules.infra-base48
		];
	};

	imports = [
		./releases # Include releases
	];

	# Export to other systems
	flake.nixosModules.machine-sinnenfreude = ./lib/sinnenfreude-export.nix;
}
