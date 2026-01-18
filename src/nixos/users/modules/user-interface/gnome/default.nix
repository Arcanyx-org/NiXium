{
	flake.homeManagerModules.ui-gnome.imports = [
		./config/networking.nix
		./config/packages.nix
	];

	imports = [ ];
}
