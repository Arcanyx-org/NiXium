{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.services.imports = [
		homeManagerModules.service-openSnitch
	];

	imports = [
		./opensnitch-ui
	];
}
