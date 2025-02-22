{ self, config, lib, ... }:

# Global Lanzaboote Management Module

let
	inherit (lib) mkForce mkIf mkDefault;
in mkIf config.boot.lanzaboote.enable {
	boot.loader.systemd-boot.enable = mkForce false; # Lanzeboote uses it's own module and requires this disabled

	boot.lanzaboote.pkiBundle = mkDefault "/var/lib/sbctl";

	# Impermanence
	environment.persistence."/nix/persist/system".directories = mkIf config.boot.impermanence.enable [
		config.boot.lanzaboote.pkiBundle
	];
}
