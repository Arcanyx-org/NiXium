{ config, inputs, self, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	# Module
	flake.homeManagerModules."kreyren@sinnenfreude".imports = [
		homeManagerModules.kreyren
		{
			home-manager = {
				users.kreyren.imports = [
					./home-configuration.nix
				];
				backupFileExtension = "backup"; # To avoid build failures on generated files
			};
		}
	];

	# # Standalone declaration
	# flake.homeManagerConfigurations."kreyren@sinnenfreude" = inputs.home-manager-nixpkgs.lib.homeManagerConfiguration {
	# 	pkgs = import inputs.nixpkgs {
	# 		system = "x86_64-linux";
	# 		nixpkgs.config.allowUnfree = true;
	# 	};
	# 	modules = [
	# 		{ home.stateVersion = "23.11"; }

	# 		self.nixosModules.homeManagerConfiguration.kreyren.default

	# 		./home-configuration.nix
	# 	];

	# 	extraSpecialArgs = {
	# 		unstable = import inputs.nixpkgs-unstable {
	# 			system = "x86_64-linux";
	# 			nixpkgs.config.allowUnfree = true;
	# 		};
	# 	};
	# };
}
