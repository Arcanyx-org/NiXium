{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.system-kreyren.imports = [
		homeManagerModules.system-flatpak-kreyren
		homeManagerModules.system-gtk-kreyren
		homeManagerModules.system-impermanence-kreyren
		homeManagerModules.system-nix-kreyren
		# homeManagerModules.system-pac-kreyren
	];

	# ./pac imported for module registration (VM reference), not added to
	# system-kreyren.imports to keep it inactive for the real user.
	imports = [
		./defaultApplications
		./flatpak
		./gtk
		./impermanence
		./nix
		./pac
	];
}
