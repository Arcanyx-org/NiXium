{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.services.imports = [
		homeManagerModules.service-opensnitch-ui
	];

	imports = [
		./opensnitch-ui
	];
}
