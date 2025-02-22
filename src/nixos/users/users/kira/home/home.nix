# Impurities to be purified:
## FreeCAD
### Generic
#### Use system proxy
#### Tree View Mode: Both
#### Orbit style: Turntable
#### New Shape Color: Random
### Addons
#### A2Plus
#### Fasteners
#### LCInterlocking
#### Modern-UI
#### Alternate OpenSCAD Importer
#### WebTools
### Theme
#### ExtremeProDark
## FreeTube
### Settings
#### General Settings
##### Preferred API Backend: Local API
#### Theme Settings
##### Base Theme: Dracula
##### Main Color Theme: Indigo
#### Proxy Settings
##### Enable Tor/Proxy: TRUE
##### Proxy Host: 127.0.0.1
##### Proxy Port Number: 9050 (Tor)
#### External Player Settings
##### External Player: mpv
##### Custom External Player Executable: /home/raptor/.nix-profile/bin/torsocks
##### Custom External Player Arguments: /home/raptor/.nix-profile/bin/mpv;--ytdl-format=bestvideo[height=?480][fps<=?30][vcodec!=?vp9]+bestaudio/best
#### SponsorBlock Settings
##### Enable SponsorBlock: TRUE

{ config, lib, pkgs, nixConfig, ... }:

# Common Home-Manager configuration across all systems
let
	inherit (lib) mkIf;
in {
	home.username = "kira";
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

		pkgs.cryptsetup

		pkgs.xclip
		pkgs.mpv
		pkgs.torsocks

		pkgs.wakeonlan

		# Command-line Pastebins
		# pkgs.ix # Long-Term Down
		pkgs.pb_cli
		pkgs.wgetpaste
	];
}
