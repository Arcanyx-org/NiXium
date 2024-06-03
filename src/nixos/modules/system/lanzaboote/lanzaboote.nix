{ self, config, lib, ... }:

# Global Lanzaboote Management Module

let
	inherit (lib) mkForce mkIf mkDefault;
in mkIf config.boot.lanzaboote.enable {
	boot.loader.systemd-boot.enable = mkForce false; # Lanzeboote uses it's own module and requires this disabled

	boot.lanzaboote.pkiBundle = mkDefault "/etc/secureboot";
}
