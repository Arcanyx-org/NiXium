{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.system-kreyren.imports = [
		homeManagerModules.system-flatpak-kreyren
		homeManagerModules.system-gtk-kreyren
		homeManagerModules.system-impermanence-kreyren
		homeManagerModules.system-nix-kreyren
		homeManagerModules.system-pac-kreyren
	];

	imports = [
		./flatpak
		./gtk
		./impermanence
		./nix
		./pac
	];
}
