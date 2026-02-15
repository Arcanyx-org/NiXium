{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.scripts-ssh-kreyren.imports = [
		homeManagerModules.scripts-ssh-ignucius-kreyren
		homeManagerModules.scripts-ssh-lengo-kreyren
		homeManagerModules.scripts-ssh-morph-kreyren
		homeManagerModules.scripts-ssh-mracek-kreyren
		homeManagerModules.scripts-ssh-sinnenfreude-kreyren
		homeManagerModules.scripts-ssh-tupac-kreyren
	];

	imports = [
		./ignucius
		./lengo
		./morph
		./mracek
		./sinnenfreude
		./tupac
	];
}
