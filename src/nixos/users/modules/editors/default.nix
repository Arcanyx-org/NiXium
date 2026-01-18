{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.editors.imports = [
		homeManagerModules.editors-vscode
	];

	imports = [
		./vscode
	];
}
