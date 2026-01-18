{
	flake.homeManagerModules.ui-gnome-kreyren.imports = [
		./config/input.nix
		./config/nightlight-filter.nix
		./config/shortcuts.nix
		./config/touchpad.nix
		./config/usability.nix
		./config/weather.nix
	];

	imports = [
		./themes
	];
}
