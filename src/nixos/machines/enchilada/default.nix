{ self, ... }:
let
	inherit (self.lib) mkVM;
in {
	# Flake management of ENCHILADA system
	flake.nixosModules."nixos-enchilada" = {
		imports = [
			self.nixosModules.default # Load NiXium's Global configuration

			(import "${self.inputs.mobile-nixos}/lib/configuration.nix" { device = "oneplus-enchilada"; })

			# Users
			self.nixosModules.users-kreyren
			# self.homeManagerModules."kreyren@enchilada"

		# Files
		./config/autoUpgrade.nix
		./config/filesystem.nix
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

	perSystem = { system, pkgs, ... }:
		let
			vm = mkVM {
				inherit pkgs;
				system = "aarch64-linux";
				name = "enchilada-debug";
				command = "bash";
				modulePath = "$FLAKE_ROOT/src/nixos/machines/enchilada";
				graphical = null;
				user = "kreyren";
				extraModules = [
					./config/setup.nix
					./config/security.nix
					./config/sound.nix
					self.nixosModules.users-kreyren
				];
			};
		in {
			packages."nixos-vm-enchilada-debug" = vm.vm;
			apps."nixos-vm-enchilada-debug" = {
				type = "app";
				program = "${vm.runner}/bin/nixos-vm-enchilada-debug";
			};
		};
}
