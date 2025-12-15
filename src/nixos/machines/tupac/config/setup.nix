{ self, config, pkgs, lib, unstable, ... }:

# The Setup of TUPAC system

# FIXME(Krey): Move this into releases as this changes with new release

let
	inherit (lib) mkIf mkForce;
in {
	networking.hostName = "tupac";

	boot.impermanence.enable = true; # Whether To Use Impermanence

	boot.plymouth.enable = true; # Show eyecandy on bootup?

	nix.distributedBuilds = true; # Perform distributed builds

	programs.adb.enable = true;
	programs.gamemode.enable = true;
		programs.gamemode.enableRenice = true;
		programs.gamemode.settings = {
			general = {
				renice = 10;
			};

			# Warning: GPU optimisations have the potential to damage hardware
			gpu = {
				apply_gpu_optimisations = "accept-responsibility";
				gpu_device = 1;
			};

			# custom = {
			# 	start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
			# 	end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
			# };
		};
	programs.steam.enable = true;
	programs.noisetorch.enable = true; # Microphone filtering
	programs.nix-ld.enable = true;
	programs.appimage = {
		enable = true;
		binfmt = true;
		package = pkgs.appimage-run.override {
			extraPkgs = pkgs: [
				# FIXME(Krey): Once we figure out what packages are in general needed for appimages then move this into a global configuration
				# Some packages need this dependency, added for utility - https://github.com/NixOS/nixpkgs/issues/350383#issuecomment-2433316461
				pkgs.libepoxy

				# Required by Melon Launcher's AppImage (https://github.com/LykosAI/StabilityMatrix/issues/554)
					# * Process terminated. Couldn't find a valid ICU package installed on the system. Please install libicu (or icu-libs) using your package manager and try again. Alternatively you can set the configuration flag System.Globalization.Invariant to true if you want to run with no globalization support. Please see https://aka.ms/dotnet-missing-libicu for more information.
					# * May be by bypasseded with:
					# ** DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
					# ** DOTNET_SYSTEM_GLOBALIZATION_PREDEFINED_CULTURES_ONLY=false
					pkgs.icu77
					pkgs.libxcrypt-legacy # https://github.com/LykosAI/StabilityMatrix/issues/554#issuecomment-2798941427
					pkgs.python312
					pkgs.python312Packages.torch

					pkgs.webkitgtk_4_1 # libwebkit2gtk-4.1.so.0
					pkgs.webkitgtk_4_0 # libwebkit2gtk-4.0.so.0

					pkgs.openxr-loader
			];
		};
	};

	xdg.portal.xdgOpenUsePortal = true;

	services.flatpak.enable = true;
	services.openssh.enable = true;
	services.tor.enable = true;
	services.hardware.openrgb.enable = false;
	services.gvfs.enable = true;
	# TODO(Krey): Pending Management
		services.usbguard.dbus.enable = false;
	services.smartd.enable = true;
	services.clamav.daemon.enable = true;
	services.ollama.enable = true;
		services.open-webui.enable = true;
		users.users.alpaka = {
			description = "Alpaka";
			uid = 1050;
			isNormalUser = true;
			createHome = true;
			extraGroups = [
				(mkIf config.virtualisation.docker.enable "docker")
				(mkIf config.programs.adb.enable "adbusers")
				"video"
			];
			openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHmtDqiOqgXx0WaJE3C+DWCdTegP6vC74/ICAcmA5xja kreyren@tupac" ];
		};

		nix.settings.trusted-users = [ "kreyren" ]; # Add Kreyren in Trusted-Users

	# FIXME(Krey): Pending work
		services.opensnitch.enable = false;
	services.printing.enable = true;
	services.sunshine.enable = true;
	programs.localsend.enable = true;
		programs.localsend.openFirewall = true;
	# services.rustdesk-server.enable = true;
	# 	services.rustdesk-server.openFirewall = tru
	services.usbmuxd.enable = true;
	# services.undervolt = {
	# 	enable = true;
	# 	tempAc = 97;
	# 	tempBat = 75;
	# 	# coreOffset = -100;
	# 	# gpuOffset = -30;
	# 	#uncoreOffset = -50;
	# 	#analogioOffset = -50;
	# };
	services.wivrn.enable = true;

	# Power Management
	powerManagement.enable = true;
	powerManagement.powertop.enable = true;
	services.tlp.enable = false;
		services.power-profiles-daemon.enable = true;

	networking.wireguard.enable = false;

	security.sudo.enable = false;
	security.sudo-rs.enable = true;

	virtualisation.waydroid.enable = true;
	virtualisation.docker.enable = true;

	nix.channel.enable = true; # To be able to use nix repl :l <nixpkgs> as loading flake loads only 16 variables

	users.users.root.openssh.authorizedKeys.keys = mkIf config.services.openssh.enable [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve kreyren@fsfe.org" # Allow root access for the Super Administrator (KREYREN)
	];

	programs.ssh.knownHosts."localhost".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpbUbuXYWfIdh4w3FI++1/1Zwhg/ow/FVr8r2kC1bhL";

	# Desktop Environment
	services.xserver.enable = true;
	services.xserver.displayManager.gdm.enable = true;
	services.xserver.desktopManager.gnome.enable = true;
		programs.dconf.enable = true; # Needed for home-manager to not fail deployment (https://github.com/nix-community/home-manager/issues/3113)
		services.xserver.displayManager.gdm.autoSuspend = false;
		# services.xserver.displayManager.gdm.wayland = false; # Do not use wayland as it has CONSTANT issues

	time.timeZone = "Europe/Vienna";

	age.secrets.tupac-ssh-ed25519-private.file = ../secrets/tupac-ssh-ed25519-private.age; # Declare private key

	hardware.steam-hardware.enable = true; # Compatibility for Steam Controller

	# Necessary Evil :(
	hardware.enableRedistributableFirmware = true;
	hardware.cpu.intel.updateMicrocode = true;

	# FIXME(Krey): This should be managed elsewhere
	nixpkgs.hostPlatform = "x86_64-linux";

	system.autoUpgrade.enable = true;

	# De-NixOSfy Experiment - Remove cache.nixos.org and build from source instead THE GOOD OLD GENTOO WAY!
		# FIXME(Krey): Pending infrastructural management as this is too computationally demanding rn
		# FIXME-INFRA(Krey): Figured out the hard way that even with GitHub OAuth Token set which significantly expands the API Rate Limit we still hit it in not even 5 min
		# nix.settings = {
		# 	substituters = mkForce [];
		# 	trusted-public-keys = mkForce [];
		# };
}
