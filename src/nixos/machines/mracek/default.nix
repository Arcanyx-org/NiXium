{ self, ... }:

# Flake management of MRACEK system

{
	# FIXME(Krey): Sub-optimal — _derivationName is used because alias resolution via
	# derivation path comparison (nix eval + toplevel.outPath) fails when configs can't
	# evaluate their toplevel (missing paths, broken modules, etc.)
	flake.nixosConfigurations."nixos-mracek" = self.nixosConfigurations."nixos-mracek-stable" // { _derivationName = "nixos-mracek-stable"; };

	flake.nixosModules."nixos-mracek" = {
		imports = [
			self.nixosModules.default # Load NiXium's Global configuration

			{
				networking.hostName = "mracek";

				# NOTE(Krey): Experimenting..
					time.timeZone = "Europe/Vienna"; # Set Timezone

				nixpkgs.hostPlatform = "x86_64-linux";
			}

			# Files
				./config/autoUpgrade.nix
				./config/bootloader.nix
				./config/disks.nix
				./config/firmware.nix
				./config/hardware-acceleration.nix
				./config/hardware.nix
				./config/initrd.nix
				./config/kernel.nix
				./config/networking.nix
				./config/plymouth.nix
				./config/security.nix
				./config/sound.nix
				./config/vm-build.nix

				./services/binfmt.nix
				./services/distributedBuilds.nix
				./services/gitea.nix
				./services/monero.nix
				./services/murmur.nix
				./services/navidrome.nix
				./services/nextcloud.nix
				./services/nginx.nix
				./services/openssh.nix
				./services/tor.nix
				./services/vaultwarden.nix
				./services/vikunja.nix
		];
	};

	imports = [
		./releases # Include system releases
	];

	# Module export to other systems in the infrastructure
	flake.nixosModules.machine-mracek = ./lib/mracek-export.nix;
}
