# FIXME-VM(Krey): Not possible to test in VM — the module includes an age
# secret (kreyren-wireproxy-protonvpn-config) which is not decryptable in VMs
# (no ragenix identity). See the apps/opencode deferral for the same reason.

{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.vpn-kreyren.imports = [
		homeManagerModules.vpn-protonvpn-kreyren
	];

	flake.homeManagerModules.vpn-protonvpn-kreyren = ./protonvpn-kreyren.nix;
}