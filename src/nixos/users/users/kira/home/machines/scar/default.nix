{ config, inputs, self, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	# Module
	flake.homeManagerModules."kira@scar".imports = [
		homeManagerModules.kira
		{
			home-manager.users.kira.imports = [
				./home-configuration.nix
			];
		}
	];
}
