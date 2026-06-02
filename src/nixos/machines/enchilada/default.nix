{ self, ... }:

# Flake management of ENCHILADA system

{
	flake.nixosModules."nixos-enchilada" = {
		imports = [
			self.nixosModules.default # Load NiXium's Global configuration

			(import "${self.inputs.mobile-nixos}/lib/configuration.nix" { device = "oneplus-enchilada"; })

			# Users
			self.nixosModules.users-kreyren
			# self.homeManagerModules."kreyren@enchilada"

			# Files
			./config/autoUpgrade.nix
			./config/hardware.nix
			./config/plymouth.nix
			./config/security.nix
			./config/setup.nix
			./config/sound.nix
			./config/ui.nix
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
	flake.nixosModules.machine-enchilada = ./lib/enchilada-export.nix;
}
