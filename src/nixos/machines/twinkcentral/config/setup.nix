{ config, lib, pkgs, ... }:

# Setup of TWINKCENTRLA

let
	inherit (lib) mkIf mkForce;
in {
	networking.hostName = "twinkcentral";

	boot.impermanence.enable = true; # Use impermanence

	boot.plymouth.enable = true;

	nix.distributedBuilds = true; # Perform distributed builds

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
	# services.thinkfan.enable = true;
	powerManagement.powertop.enable = true;

	networking.wireguard.enable = false;

	security.sudo.enable = false;
	security.sudo-rs.enable = true;

	virtualisation.waydroid.enable = false;
	virtualisation.docker.enable = false;

	nix.channel.enable = true; # To be able to use nix repl :l <nixpkgs> as loading flake loads only 16 variables

	users.users.root.openssh.authorizedKeys.keys = mkIf config.services.openssh.enable [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve kreyren@fsfe.org" # Allow root access for the Super Administrator (KREYREN)
	];
	programs.ssh.knownHosts."localhost".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHcHEgNyhsjEHGaRXKuKopjSgthEn831KGnAXc0c/fLV";

	# Desktop Environment
	services.xserver.enable = false;
	services.xserver.displayManager.gdm.enable = false;
	services.xserver.displayManager.gdm.wayland = false; # Do not use wayland as it has issues rn
	services.xserver.desktopManager.gnome.enable = false;
		programs.dconf.enable = true; # Needed for home-manager to not fail deployment (https://github.com/nix-community/home-manager/issues/3113)
		services.xserver.displayManager.gdm.autoSuspend = false;

	# Power Management
	powerManagement.enable = true; # Enable Power Management
	services.tlp.enable = false; # TLP-Based Managemnt (For Fine Tuning)
	services.power-profiles-daemon.enable = true; # PPD-Based Management (Predefined through system data only)

	# Extending life of the SSD
	# services.fstrim.enable = true;

	age.secrets.twinkcentral-ssh-ed25519-private.file = ../secrets/twinkcentral-ssh-ed25519-private.age; # Declare private key

	nixpkgs.hostPlatform = "x86_64-linux";

	# De-NixOSfy Experiment - Remove cache.nixos.org and build from source instead THE GOOD OLD GENTOO WAY!
		# FIXME(Krey): Pending infrastructural management as this is too computationally demanding rn
		# FIXME-INFRA(Krey): Figured out the hard way that even with GitHub OAuth Token set which significantly expands the API Rate Limit we still hit it in not even 5 min
		nix.settings = {
			substituters = mkForce [];
			trusted-public-keys = mkForce [];
		};
}
