{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.editors-kreyren.imports = [
		homeManagerModules.editors-vim-kreyren
		homeManagerModules.editors-vscode-kreyren
	];

	imports = [
		./vim
		./vscode
	];
}
