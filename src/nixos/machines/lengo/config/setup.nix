{ config, lib, pkgs, unstable, ... }:

# Setup of LENGO

# Boot: See what it is taking most time: `systemd-analyze critical-chain`

let
	inherit (lib) mkForce mkIf;
in {
	networking.hostName = "lengo";

	boot.impermanence.enable = true; # Use impermanence

	boot.plymouth.enable = true;

	nix.distributedBuilds = false; # Perform distributed builds

	programs.adb.enable = true;
	# programs.envision.enable = true;
	programs.noisetorch.enable = true;
	programs.nix-ld.enable = true;
	programs.appimage = {
		enable = true;
		binfmt = true;
	};

	services.openssh.enable = true;
	services.tor.enable = true;
	# FIXME(Krey): Pending Management, seems to add a lot of pain with not enough benefit
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
	services.xserver.enable = false;
	services.xserver.desktopManager.kodi.enable = true;
	services.xserver.displayManager.gdm.enable = true;
		services.xserver.displayManager.gdm.wayland = true; # Do not use wayland as it has issues rn
		# FIXME(Krey): Enable screen keyboard by default in GDM (minor inconvinience)
			# This doesn't work?
			# systemd.services.enable-screen-keyboard-gdm = {
			# 	description = "Enable Screen Keyboard in GDM";
			# 	wantedBy = [ "multi-user.target" ];
			# 	after = [ "local-fs.target" ];  # Ensure this runs after the filesystem is mounted
			# 	script = builtins.concatStringsSep "\n" [
			# 		"${pkgs.glib}/bin/gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true"
			# 	];
			# };
	services.xserver.desktopManager.gnome.enable = true;
		programs.dconf.enable = true; # Needed for home-manager to not fail deployment (https://github.com/nix-community/home-manager/issues/3113)
		services.xserver.displayManager.gdm.autoSuspend = false;
	# To get rid of black borders around windows on GNOME using AMDVLK (https://gitlab.gnome.org/GNOME/gtk/-/issues/6890)
	environment.variables.GSK_RENDERER = "ngl";
	services.displayManager.defaultSession = "gnome";

	programs.coolercontrol.enable = true;

	# Steam
		# FIXME(Krey): Try to use the unstable release of NixOS to get later releases of Steam and proton-ge-bin to maybe make it less of a shitware?.. or probably far worse than it is already
		programs.steam = {
			enable = true;
			extest.enable = true;
			remotePlay.openFirewall = true;
			extraCompatPackages = [
				pkgs.proton-ge-bin
			];
		};

	# Power Management
		powerManagement.enable = true; # Enable Power Management
		# FIXME(Krey): Pending Management..
			services.tlp.enable = false; # TLP-Based Managemnt (For Fine Tuning)
		services.power-profiles-daemon.enable = true; # PPD-Based Management (Predefined through system data only)

	# Extending life of the SSD by trimming it
		services.fstrim.enable = true;

	# Enable sensors
		hardware.sensor.iio.enable = true;

	# HandHeld Daemon ("HHD")
		services.handheld-daemon.enable = false;
		services.handheld-daemon.ui.enable = false;
			services.handheld-daemon.user = "kira";

	# To input decrypting password in initrd
		boot.initrd.unl0kr.enable = false;

	# Jovian
	# jovian.devices.legiongo.enable = true;

	# NOTE(Krey): Doesn't seem to work correctly and seem funcitonaly inferior to lact
		# programs.corectrl.enable = true;

	services.sunshine.enable = true;

	age.secrets.lengo-ssh-ed25519-private.file = ../secrets/lengo-ssh-ed25519-private.age; # Declare private key

	nixpkgs.hostPlatform = "x86_64-linux";
}
