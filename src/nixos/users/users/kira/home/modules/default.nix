{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.modules-kira.imports = [
		homeManagerModules.system-kira
		homeManagerModules.ui-kira
		homeManagerModules.vpn-protonvpn-kira
	];

	imports = [
		./system
		./user-interface
		./vpn
	];
}
