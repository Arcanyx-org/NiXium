{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.terminal-emulators.imports = [
		homeManagerModules.terminal-emulators-alacritty
	];

	imports = [
		./alacritty
	];
}
