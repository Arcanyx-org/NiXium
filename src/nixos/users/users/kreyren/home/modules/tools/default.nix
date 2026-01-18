{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.tools-kreyren.imports = [
		homeManagerModules.tools-git-kreyren
		homeManagerModules.tools-gpg-agent-kreyren
		homeManagerModules.tools-ragenix-kreyren
	];

	imports = [
		./git
		./gpg-agent
		./ragenix
	];
}
