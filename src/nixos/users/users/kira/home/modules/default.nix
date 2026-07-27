{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.modules-kira.imports = [
		homeManagerModules.program-kira
		homeManagerModules.prompts-kira
		homeManagerModules.system-kira
		homeManagerModules.ui-kira
		homeManagerModules.vpn-protonvpn-kira
		homeManagerModules.web-browsers-kira
	];

	imports = [
		./program
		./prompts
		./system
		./user-interface
		./vpn
		./web-browsers
	];
}
