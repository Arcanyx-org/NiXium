{ config, lib, pkgs, ... }:

# Setup of LENGO

let
	inherit (lib) mkIf;
in {
	networking.hostName = "lengo";

	boot.impermanence.enable = true; # Use impermanence

	boot.plymouth.enable = true;

	nix.distributedBuilds = false; # Perform distributed builds

	programs.noisetorch.enable = true;
	programs.adb.enable = true;
	programs.nix-ld.enable = true;
	programs.appimage = {
		enable = true;
		binfmt = true;
	};

	services.openssh.enable = true;
	services.tor.enable = true;
	# TODO(Krey): Pending Management
		services.usbguard.dbus.enable = false;
	services.clamav.daemon.enable = true;
	services.printing.enable = true;
	powerManagement.powertop.enable = true;

	networking.wireguard.enable = false;

	security.sudo.enable = false;
	security.sudo-rs.enable = true;

	virtualisation.waydroid.enable = true;
	virtualisation.docker.enable = false;

	nix.channel.enable = true; # To be able to use nix repl :l <nixpkgs> as loading flake loads only 16 variables

	users.users.root.openssh.authorizedKeys.keys = mkIf config.services.openssh.enable [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve kreyren@fsfe.org" # Allow root access for the Super Administrator (KREYREN)
	];
	programs.ssh.knownHosts."localhost".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKWL1P+3Bg7rr3NEW2h0I1bXBZtwCpU3IiruewsUQrcg";

	# Desktop Environment
	services.xserver.enable = true;
	services.xserver.displayManager.gdm.enable = false;
	# services.xserver.displayManager.gdm.wayland = false; # Do not use wayland as it has issues rn
	services.xserver.desktopManager.gnome.enable = true;
		programs.dconf.enable = true; # Needed for home-manager to not fail deployment (https://github.com/nix-community/home-manager/issues/3113)
		services.xserver.displayManager.gdm.autoSuspend = false;

	# FIXME(Krey): Figure out how to handle this
	# Japanese Keyboard Input
	# i18n.inputMethod.enable = true;
	# i18n.inputMethod.type = "fcitx5";
	# i18n.inputMethod.fcitx5.addons = with pkgs; [ fcitx5-mozc ];

	# Power Management
	powerManagement.enable = true; # Enable Power Management
	# FIXME(Krey): Pending Management..
		services.tlp.enable = false; # TLP-Based Managemnt (For Fine Tuning)
	services.power-profiles-daemon.enable = true; # PPD-Based Management (Predefined through system data only)

	# Extending life of the SSD
	services.fstrim.enable = true;

	# Enable sensors
	hardware.sensor.iio.enable = true;

	# HHH
	services.handheld-daemon.enable = true;
	services.handheld-daemon.ui.enable = true;
	services.handheld-daemon.user = "kira";

	# Jovian
	jovian.devices.legiongo.enable = true;
	jovian.steam.desktopSession = "gnome";
	jovian.steam = {
		user = "kira";
		enable = true;
		autoStart = true;
	};
	# FIXME(Krey): Fails due to missing python3
	jovian.decky-loader = {
		user = "kira";
		enable = true;
	};
	programs.steam = {
		enable = true;
		extest.enable = true;
		remotePlay.openFirewall = true;
		extraCompatPackages = [
			pkgs.proton-ge-bin
		];
	};
	# ~/.steam/steam/.cef-enable-remote-debugging

	age.secrets.lengo-ssh-ed25519-private.file = ../secrets/lengo-ssh-ed25519-private.age; # Declare private key

	nixpkgs.hostPlatform = "x86_64-linux";
}
