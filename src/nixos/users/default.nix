{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.default = {
		imports = [
			homeManagerModules.editors
			homeManagerModules.services
			homeManagerModules.system
			homeManagerModules.terminal-emulators
			homeManagerModules.tools
			homeManagerModules.ui-gnome
			homeManagerModules.web-browsers
		];
	};

	imports = [
		./users
		./modules
	];
}
