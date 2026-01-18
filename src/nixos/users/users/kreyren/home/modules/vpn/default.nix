{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.vpn-kreyren.imports = [
		homeManagerModules.vpn-protonvpn-kreyren
	];

	flake.homeManagerModules.vpn-protonvpn-kreyren = ./protonvpn-kreyren.nix;
}
