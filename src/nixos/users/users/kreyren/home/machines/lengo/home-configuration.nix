{ config, pkgs, lib, unstable, aagl, nixosConfig, polymc, ... }:

# Kreyren's Home-Manager configuration for the IGNUCIUS system

let
	inherit (lib) mkIf getName;
	inherit (builtins) elem;
in {
	# TODO(Krey): Enable this only when GTK is used by the UI
	gtk.enable = true;

	home.impermanence.enable = true;

	# Terminal
		# TOOD(Krey): Different UIs will likely require different terminal solutions.. Decide how to handle later..
		programs.alacritty.enable = true; # Rust-based Video-accelarated terminal
		# FIXME(Krey): Doesn't work with scaling below 100% on GNOME
		programs.kitty.enable = false; # Alternative Rust-based Hardware-accelarated terminal for testing, potentially superrior to alacritty

	# Shell
		# TODO(Krey): Different UIs will likely require different shell solutions, decide how to handle later..
		programs.bash.enable = true;
		programs.starship.enable = true;

	# Utilities
		programs.direnv.enable = true; # To manage git repositories
		programs.git.enable = true; # Generic use only
		programs.gpg.enable = true;
		programs.nix-index.enable = true;
		services.gpg-agent.enable = true;

	# Web Browsers
		programs.firefox.enable = true; # Configured as fully hardened web browser (Privacy > Comfort)
		programs.librewolf.enable = true; # Configured as lesser security web browser (Comfort > Privacy)

	# File Editors
		programs.vim.enable = true;
		programs.vscode.enable = true;

	# Non-Free Allow List
	nixpkgs.config.allowUnfreePredicate = pkg: elem (getName pkg) [
		# FIXME(Krey): Using vscodium, no idea why this needs 'vscode' set
		"vscode"

		# FIXME(Krey): It's ET: Legacy, what's proprietary there?
		"etlegacy"
		"etlegacy-assets"
	];

	home.packages = [
		# Instant-Chats
				# (mkIf config.gtk.enable pkgs.fractal) # GTK4+ Matrix Client Written in Rust
			# FIXME-QA(Krey): Enable this on QT-based desktop environments
				# pkgs.nheko # QT-based Matrix Client

			# Session uses system proxy by default which breaks functionality
			(pkgs.session-desktop.overrideAttrs (super: {
				postInstall = ''
					wrapProgram $out/bin/session-desktop \
						--append-flags "--no-proxy-server"
				'';
			}))
			# Temporary managment of IRC until it's implemented in our matrix server
			pkgs.hexchat # Unmaintained package, no better known for the protocol

			# Discord client for flexibility
			pkgs.dissent

		pkgs.libreoffice

		# TODO(Krey): Takes ages to build on the local system, pending compute server
		polymc.polymc

		# 3D Printing Slicers
		pkgs.prusa-slicer
		pkgs.super-slicer-beta # Prusa-slicer fork by community. Includes additional features, but lags behind in releases
		pkgs.orca-slicer # Prusa-slicer fork by BambuLab adapted by the community

		# Games
		aagl.anime-game-launcher # An Anime Game <3
		pkgs.colobot
		pkgs.etlegacy # Wolfenstein: Enemy Territory
		pkgs.airshipper # Veloren
		pkgs.mindustry

		# Web Browsers
		pkgs.tor-browser-bundle-bin # Standard Tor Web Browser
		(pkgs.brave.overrideAttrs (super: {
			postInstall = ''
				wrapProgram $out/bin/brave \
					--append-flags "--no-proxy-server"
			'';
		})) # Standard Insecure Web Browser

		# Engineering
		pkgs.blender
		pkgs.freecad
		pkgs.gimp
		pkgs.kicad-small

		# Utility
		pkgs.keepassxc
		pkgs.yt-dlp
		pkgs.android-tools
		pkgs.picocom # Interface for Serial Console devices
		pkgs.bottles # Wine Management Tool
		pkgs.mtr # Packet Loss Tester
		pkgs.sc-controller # Steam Controller Software
		pkgs.monero-gui
		pkgs.dialect # Language Translator
		pkgs.endeavour # To-Do Notes
		# FIXME-QA(Krey): As of 24th Jun 2024 this doesn't build
			# pkgs.gaphor # Mind Maps
		# TODO(Krey): This should probably be applied depending on the used UI
			pkgs.kooha # Screen Recorder
		# FIXME(Krey): Broken in stable
		pkgs.qbittorrent # Torrents
		pkgs.tealdeer # TLDR Pages Implementation
		pkgs.nextcloud-client
		# FIXME(Krey): To be managed..
		#(mkIf (config.system.nixos.release != "24.11") pkgs.printrun) # Currently broken in unstable+

		# Video
		pkgs.stremio # Media Server Client
		pkgs.freetube # YouTube Client
		pkgs.mpv
		pkgs.vlc

		# Keyboard
		# FIXME-PKGS(Krey): Bump this in pkgs
		# pkgs.gnomeExtensions.gjs-osk
	];

	# Per-system adjustments to the GNOME Extensions
	# TODO(Krey): This should be applied based on used UI
	dconf.settings = mkIf nixosConfig.services.xserver.desktopManager.gnome.enable {
		# Set power management for a scenario where user is logged-in
		"org/gnome/settings-daemon/plugins/power" = {
			power-button-action = "hibernate";
			sleep-inactive-ac-timeout = 600; # 60*10=600 Seconds -> 10 Minutes
			sleep-inactive-ac-type = "suspend";
		};

		# System Monitor
		"org/gnome/gnome-system-monitor" = {
			show-dependencies = false;
			show-whose-processes= "user";
		};

		"org/gnome/gnome-system-monitor/disktreenew" = {
			col-6-visible = true;
			col-6-width = 0;
		};

		"org/gnome/shell/extensions/vitals" = {
			fixed-widths = true;
			hide-icons = true;
			hide-zeros = false;
			icon-style = 1;
			include-static-info = false;
			menu-centered = false;
			network-speed-format = 1;
			position-in-panel = 0;
			show-battery = true;
			show-gpu = false; # Nvidia only, system without dGPU
			update-time = 3;
			use-higher-precision = true;

			hot-sensors = [
				"__temperature_max__"
				"_system_load_1m_"
				"_memory_usage_"
				"__network-tx_max__"
				"__network-rx_max__"
				"_battery_rate_"
				"_fan_thinkpad_fan1_"
			];
		};
	};
}
