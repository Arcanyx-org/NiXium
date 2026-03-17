{ config, lib, pkgs, nixConfig, ... }:

# Common Home-Manager configuration across all systems
let
	inherit (lib) mkIf;
in {
	home.username = "Tester";
	home.homeDirectory = ("/home/" + config.home.username);

	systemd.user.startServices = true; # Start all needed services on activation and deactivate the obsolets instead of suggesting what to do

	xsession.numlock.enable = true; # Enable numlock on boot

	# Global Packages Installed On ALL Systems
	home.packages = [];
}
