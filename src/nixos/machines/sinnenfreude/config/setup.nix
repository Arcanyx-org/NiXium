{ config, pkgs, lib, ... }:

# The Setup of SINNENFREUDE system

let
	inherit (lib) mkIf mkForce;
in {
	networking.hostName = "sinnenfreude";

	boot.impermanence.enable = true; # Use impermanence

	boot.plymouth.enable = true;

	nix.distributedBuilds = true; # Perform distributed builds

	programs.noisetorch.enable = true;
	programs.adb.enable = true;
	programs.nix-ld.enable = true;
	programs.appimage = {
		enable = true;
		binfmt = true;
		package = pkgs.appimage-run.override {
			extraPkgs = pkgs: [
				# FIXME(Krey): Once we figure out what packages are in general needed for appimages then move this into a global configuration
				# Some packages need this dependency, added for utility - https://github.com/NixOS/nixpkgs/issues/350383#issuecomment-2433316461
				pkgs.libepoxy
			];
		};
	};

	services.flatpak.enable = true;
	services.openssh.enable = true;
	services.tor.enable = true;
	# TODO(Krey): Pending Management
		services.usbguard.dbus.enable = false;
	services.smartd.enable = true;
	services.clamav.daemon.enable = true;
	services.printing.enable = true;
	# services.rustdesk-server.enable = true;
	# 	services.rustdesk-server.openFirewall = tru
	services.usbmuxd.enable = true;

	powerManagement.powertop.enable = true;

	networking.wireguard.enable = false;

	security.sudo.enable = false;
	security.sudo-rs.enable = true;

	virtualisation.waydroid.enable = true;
	virtualisation.docker.enable = true;

	nix.channel.enable = true; # To be able to use nix repl :l <nixpkgs> as loading flake loads only 16 variables

	users.users.root.openssh.authorizedKeys.keys = mkIf config.services.openssh.enable [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve kreyren@fsfe.org" # Allow root access for the Super Administrator (KREYREN)
	];
	programs.ssh.knownHosts."localhost".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIAXnS4xUPWwjBdKDvvy5OInLbs3oeHUUs5qUsX+fBji";

	# Desktop Environment
	services.xserver.enable = true;
	services.xserver.displayManager.gdm.enable = true;
	services.xserver.desktopManager.gnome.enable = true;
		programs.dconf.enable = true; # Needed for home-manager to not fail deployment (https://github.com/nix-community/home-manager/issues/3113)
		services.xserver.displayManager.gdm.autoSuspend = false;
		services.xserver.displayManager.gdm.wayland = false; # Do not use wayland as it has CONSTANT issues

	# hardware.steam-hardware.enable = true;

	# Japanese Keyboard Input
	i18n.inputMethod.enabled = "fcitx5";
	i18n.inputMethod.fcitx5.addons = with pkgs; [ fcitx5-mozc ];

	age.secrets.sinnenfreude-ssh-ed25519-private.file = ../secrets/sinnenfreude-ssh-ed25519-private.age; # Declare private key

	# Necessary Evil :(
	hardware.enableRedistributableFirmware = true;
	hardware.cpu.intel.updateMicrocode = true;

	nixpkgs.hostPlatform = "x86_64-linux";

	# NOTE(Krey): Experimenting..
	time.timeZone = "Europe/Vienna"; # Set Timezone

	# De-NixOSfy Experiment - Remove cache.nixos.org and build from source instead THE GOOD OLD GENTOO WAY!
		# FIXME(Krey): Pending infrastructural management as this is too computationally demanding rn
		# FIXME-INFRA(Krey): Figured out the hard way that even with GitHub OAuth Token set which significantly expands the API Rate Limit we still hit it in not even 5 min
		# nix.settings = {
		# 	substituters = mkForce [];
		# 	trusted-public-keys = mkForce [];
		# };

	# Miracast
		networking.firewall.allowedTCPPorts = [7236 7250];
		networking.firewall.allowedUDPPorts = [7236 5353];
}
