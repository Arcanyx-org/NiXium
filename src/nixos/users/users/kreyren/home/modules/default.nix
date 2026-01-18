{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.modules-kreyren.imports = [
		homeManagerModules.apps-kreyren
		homeManagerModules.editors-kreyren
		homeManagerModules.prompts-kreyren
		homeManagerModules.scripts-kreyren
		homeManagerModules.shells-kreyren
		homeManagerModules.system-kreyren
		homeManagerModules.terminal-emulators-kreyren
		homeManagerModules.tools-kreyren
		homeManagerModules.ui-kreyren
		homeManagerModules.vpn-kreyren
		homeManagerModules.web-browsers-kreyren
	];

	imports = [
		./apps
		./editors
		./prompts
		./scripts
		./shells
		./system
		./terminal-emulators
		./tools
		./user-interface
		./vpn
		./web-browsers
	];
}
