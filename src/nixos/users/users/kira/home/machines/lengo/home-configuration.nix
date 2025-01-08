{ config, pkgs, lib, unstable, aagl-unstable, nixosConfig, polymc, ... }:

# Kreyren's Home-Manager configuration for the LENGO system

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
		programs.bash.enable = true;

	# Utilities
		programs.direnv.enable = true; # To manage git repositories
		programs.git.enable = true; # Generic use only
		programs.nix-index.enable = true;

	# Web Browsers
		programs.firefox.enable = true;
		programs.librewolf.enable = true;

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

		# Flexibility of communication with some projects that hate privacy or what the fuck
		"discord"
	];

	home.packages = [
		pkgs.libreoffice

		# TODO(Krey): Takes ages to build on the local system, pending compute server
		polymc.polymc

		# Games
		aagl-unstable.anime-game-launcher # An Anime Game <3
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


		pkgs.bottles # Wine Management Tool
		pkgs.qbittorrent # Torrents
		pkgs.tealdeer # TLDR Pages Implementation
		pkgs.nextcloud-client

		# Video
		pkgs.stremio # Media Server Client
		pkgs.freetube # YouTube Client
		pkgs.mpv
		pkgs.vlc

		# Keyboard
		# FIXME(Krey): Outdated..
		pkgs.gnomeExtensions.gjs-osk
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
