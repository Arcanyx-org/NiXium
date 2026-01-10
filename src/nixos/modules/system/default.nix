{ config, lib, ... }:

# Global System Management

let
	inherit (config.flake) nixosModules;
in {
	flake.nixosModules.system.imports = [
		nixosModules.system-bootloader
		nixosModules.system-ccache
		nixosModules.system-clamav
		nixosModules.system-docker
		nixosModules.system-environment
		nixosModules.system-firewall
		nixosModules.system-impermenance
		nixosModules.system-kernel
		nixosModules.system-lanzaboote
		nixosModules.system-locale
		nixosModules.system-nix
		nixosModules.system-pipewire
		nixosModules.system-release
		nixosModules.system-time
		nixosModules.system-wifi
	];

	imports = [
		./bootloader
		./ccache
		./clamav
		./docker
		./environment
		./firewall
		./impermenance
		./kernel
		./lanzaboote
		./locale
		./nix
		./pipewire
		./release
		./time
		./wifi
	];
}
