{ self, ... }:

# Flake management of MRACEK system

{
	flake.nixosModules."nixos-mracek" = {
		imports = [
			self.nixosModules.default # Load NiXium's Global configuration

			# Files
			./services/binfmt.nix
			./services/distributedBuilds.nix
			./services/gitea.nix
			./services/monero.nix
			./services/murmur.nix
			./services/navidrome.nix
			./services/openssh.nix
			./services/tor.nix
			./services/vaultwarden.nix
			./services/vikunja.nix

			./config/bootloader.nix
			./config/disks.nix
			./config/firmware.nix
			./config/hardware-acceleration.nix
			./config/initrd.nix
			./config/kernel.nix
			./config/networking.nix
			./config/power-management.nix
			./config/remote-unlock.nix
			./config/security.nix
			./config/setup.nix
			./config/sound.nix
			./config/vm-build.nix
		];
	};

	imports = [
		./releases # Include system releases
	];

	# Module export to other systems in the infrastructure
	flake.nixosModules.machine-mracek = ./lib/mracek-export.nix;
}
