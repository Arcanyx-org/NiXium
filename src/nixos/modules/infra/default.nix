{ config, lib, ... }:

# Global Infra Management

let
	inherit (config.flake) nixosModules;
in {
	flake.nixosModules.infra.imports = [
		nixosModules.infra-base48
	];

	imports = [
		./base48
	];
}
