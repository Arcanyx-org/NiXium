{ config, lib, pkgs, nixConfig, ... }:

# Common Home-Manager configuration across all systems
let
	inherit (lib) mkIf;
in {
	home.username = "kreyren";
	home.homeDirectory = ("/home/" + config.home.username);

	systemd.user.startServices = true; # Start all needed services on activation and deactivate the obsolets instead of suggesting what to do

	xsession.numlock.enable = true; # Enable numlock on boot

	# Global Packages Installed On ALL Systems
	home.packages = [
		pkgs.keepassxc
		pkgs.wcalc
		pkgs.ripgrep
		pkgs.pciutils # for lspci
		pkgs.file
		pkgs.tree
		pkgs.open-dyslexic
		pkgs.htop
		pkgs.unzip

		pkgs.cryptsetup

		pkgs.nmap

		pkgs.xclip
		pkgs.mpv
		pkgs.torsocks

		pkgs.wakeonlan

		pkgs.sqlitebrowser # GUI for SQLite Databases

		# Command-line Pastebins
		# pkgs.ix # Long-Term Down
		pkgs.pb_cli
		pkgs.wgetpaste
	];
}
