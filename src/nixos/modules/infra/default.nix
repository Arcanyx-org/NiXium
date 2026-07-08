{ config, ... }:

# Global Infra Management

let
	inherit (config.flake) nixosModules;
in {
	flake.nixosModules.infra.imports = [
		# nixosModules.infra-base48
		nixosModules.infra-hackint
	];

	imports = [
		./base48
		./hackint
	];
}
