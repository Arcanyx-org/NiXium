{ config, lib, pkgs, unstable, ... }:

# Setup of LENGO

# Boot: See what it is taking most time: `systemd-analyze critical-chain`

let
	inherit (lib) mkForce mkIf;
in {
	networking.hostName = "lengo";

	boot.impermanence.enable = true; # Use impermanence

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

	# Steam
	programs.steam = {
		enable = true;
		extest.enable = true;
		remotePlay.openFirewall = true;
		extraCompatPackages = [
			pkgs.proton-ge-bin
		];
	};

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

	# HHD
	services.handheld-daemon.enable = false;
	services.handheld-daemon.ui.enable = false;
	# TODO(Krey): Change on `kira` later
		services.handheld-daemon.user = "kreyren";

	# To input decrypting password in initrd
	# FIXME(Krey): This currently doesn't work complains about wrong symbol in the config and that it can't find the framebuffer device
	boot.initrd.unl0kr.enable = true;
		# unl0kr is not designed to work with plymouth
		boot.plymouth.enable = mkForce false;
		boot.initrd.unl0kr.settings = {
			keyboard.autohide = false;
			theme.default = "breezy-dark";
		};

	# Rotate screen
	boot.kernelParams = [
		"fbcon=rotate:3" # Rotate screen on landscape
		"amdgpu.ppfeaturemask=0xffffffff" # Enable overclocking
	];

	# Jovian
	# jovian.devices.legiongo.enable = true;
	# jovian.steam.desktopSession = "gnome";
	# jovian.steam = {
	# 	user = "kira";
	# 	enable = true;
	# 	autoStart = true;
	# };
	# jovian.decky-loader = {
	# 	user = "kira";
	# 	enable = true;
	# };
	# programs.steam = {
	# 	enable = true;
	# 	extest.enable = true;
	# 	remotePlay.openFirewall = true;
	# 	extraCompatPackages = [
	# 		pkgs.proton-ge-bin
	# 	];
	# };
	# # hardware.steam-hardware.enable = false;
	# # Enable CEF mode as currently it's required to get UI to load (https://github.com/Jovian-Experiments/Jovian-NixOS/issues/460)
	# systemd.services.setUserPersistPermissions = {
	# 	description = "Enable CEF Mode for Steam UI";
	# 	wantedBy = [ "multi-user.target" ];
	# 	after = [ "local-fs.target" ];  # Ensure this runs after the filesystem is mounted
	# 	script = builtins.concatStringsSep "\n" [
	# 		"${pkgs.su}/bin/su kira --command '${pkgs.coreutils}/bin/touch /home/kira/.steam/steam/.cef-enable-remote-debugging'"
	# 	];
	# };

	# Make sure that the controllers are usable
	# [  +0.018043] input: Lenovo Legion Controller for Windows as /devices/pci0000:00/0000:00:08.1/0000:c2:00.3/usb1/1-3/1-3:1.0/input>
	# [  +0.147181] usb 1-3: New USB device found, idVendor=17ef, idProduct=6182, bcdDevice= 1.00
	# [  +0.000015] usb 1-3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
	# [  +0.000006] usb 1-3: Product: Legion Controller for Windows
	# [  +0.028101] input:   Legion Controller for Windows  Touchpad as /devices/pci0000:00/0000:00:08.1/0000:c2:00.3/usb1/1-3/1-3:1.1/>
	services.udev.extraRules = builtins.concatStringsSep "\n" [
		"ACTION==\"add\", ATTRS{idVendor}==\"17ef\", ATTRS{idProduct}==\"6182\", RUN+=\"/sbin/modprobe xpad\" RUN+=\"/bin/sh -c 'echo 17ef 6182 > /sys/bus/usb/drivers/xpad/new_id'\""
	];

	systemd.services.lactd = {
		wantedBy = [ "multi-user.target" ];
		after = [ "multi-user.target" ];
		description = "AMDGPU Control Daemon";
		serviceConfig = {
			ExecStart = "${unstable.lact}/bin/lact daemon";
		};
	};
	environment.systemPackages = [ unstable.lact ];

	boot.blacklistedKernelModules = [ "xpad" ];

	# systemd.services.xboxdrv = {
	# 	wantedBy = [ "multi-user.target" ];
	# 	after = [ "network.target" ];
	# 	serviceConfig = {
	# 		Type = "forking";
	# 		User = "root";
	# 		ExecStart = "${pkgs.xboxdrv}/bin/xboxdrv --daemon --detach --pid-file /var/run/xboxdrv.pid --dbus disabled --silent --detach-kernel-driver --deadzone 4000 --deadzone-trigger 10% --mimic-xpad-wireless";
	# 	};
	# };

	hardware.xpadneo.enable = true;

	age.secrets.lengo-ssh-ed25519-private.file = ../secrets/lengo-ssh-ed25519-private.age; # Declare private key

	nixpkgs.hostPlatform = "x86_64-linux";
}
