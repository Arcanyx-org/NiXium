{ config, lib, pkgs, ... }:

# Setup of KRYPTON

let
	inherit (lib) mkIf;
in {
	networking.hostName = "krypton";

	boot.impermanence.enable = true; # Use impermanence

	boot.plymouth.enable = true;

	nix.distributedBuilds = false;

	programs.noisetorch.enable = false;
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

	services.openssh.enable = true;
	services.tor.enable = true;
	# TODO(Krey): Pending Management
		services.usbguard.dbus.enable = false;
	services.smartd.enable = false;
	services.clamav.daemon.enable = true;
	services.printing.enable = true;
	powerManagement.powertop.enable = true;

	# Sudo
		# FIXME-QA(Krey): Should be in system module
		security.sudo.enable = false;
		security.sudo-rs.enable = true;

	# FIXME(Krey): Enable later
		virtualisation.waydroid.enable = false;
		virtualisation.docker.enable = false;

	nix.channel.enable = true; # To be able to use nix repl :l <nixpkgs> as loading flake loads only 16 variables

	users.users.root.openssh.authorizedKeys.keys = mkIf config.services.openssh.enable [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve kreyren@fsfe.org" # Allow root access for the Super Administrator (KREYREN)
	];
	programs.ssh.knownHosts."localhost".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFUdaKciGgJW6QiwwFPAN2cSHwC8iEh98OEvxPWcmWf9";

	# Desktop Environment
	services.xserver.enable = false;
	services.xserver.displayManager.gdm.enable = false;
	services.xserver.displayManager.gdm.wayland = false; # Do not use wayland as it has issues rn
	services.xserver.desktopManager.gnome.enable = false;
		programs.dconf.enable = false; # Needed for home-manager to not fail deployment (https://github.com/nix-community/home-manager/issues/3113)
		services.xserver.displayManager.gdm.autoSuspend = false;

	# Fingerprint
	services.fprintd.enable = true;

	# FIXME(Krey): Figure out how to handle this
		# Japanese Keyboard Input
		# i18n.inputMethod.enable = true;
		# i18n.inputMethod.type = "fcitx5";
		# i18n.inputMethod.fcitx5.addons = with pkgs; [ fcitx5-mozc ];

	# Power Management
	powerManagement.enable = true; # Enable Power Management
	# services.tlp.enable = false; # TLP-Based Managemnt (For Fine Tuning)
	# services.power-profiles-daemon.enable = true; # PPD-Based Management (Predefined through system data only)

	# Extending life of the SSD
	# services.fstrim.enable = true;

	age.secrets.krypton-ssh-ed25519-private.file = ../secrets/krypton-ssh-ed25519-private.age; # Declare private key

	nixpkgs.hostPlatform = "aarch64-linux";
}
