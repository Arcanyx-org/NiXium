{ lib, pkgs, nixosConfig, ... }:

# Configuration of user-based OpenSnitch Service for all users

let
	inherit (lib) mkIf;
in mkIf nixosConfig.services.opensnitch.enable {
	# Opensnitch-ui is meant to be initiated and installed for all users if the service is turned on
	services.opensnitch-ui.enable = true;
	home.packages = [ pkgs.opensnitch-ui ]; # Include the package in userland

	# FIXME(Krey): Make it possible to change ~/.config/opensnitch/settings.conf to change DefaultAction
}
