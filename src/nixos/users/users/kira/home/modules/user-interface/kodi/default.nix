{
	flake.homeManagerModules.ui-kodi-kira.imports = [
		./config/packages.nix
		./kodi.nix
	];

	imports = [
		# ./themes
	];
}
