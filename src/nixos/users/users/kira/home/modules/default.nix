{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.modules-kira.imports = [
		homeManagerModules.propts-kira
		homeManagerModules.system-kira
		homeManagerModules.ui-kira
		homeManagerModules.vpn-protonvpn-kira
		homeManagerModules.web-browsers-kira
	];

	imports = [
		./system
		./user-interface
		./vpn
		./web-browsers
	];
}
