{ config, pkgs, lib, unstable, aagl, polymc, ... }:

# FIXME(Krey): trace: evaluation warning: The ‘gnome.dconf-editor’ was moved to top-level. Please use ‘pkgs.dconf-editor’ directly. -- Channel 24.11

let
	inherit (lib) mkIf;
in {
	gtk.enable = true;

	home.impermanence.enable = true;

	programs.alacritty.enable = true; # Rust-based Video-accelarated terminal
	# FIXME(Krey): Doesn't work with scaling below 100% on GNOME
	programs.bash.enable = true;
	programs.starship.enable = true;
	programs.direnv.enable = true; # To manage git repositories
	programs.git.enable = true; # Generic use only
	programs.gpg.enable = true;
	programs.firefox.enable = true; # Fully hardened web browser (Privacy > Comfort)
	programs.librewolf.enable = true; # Lesser security web browser (Comfort > Privacy)
	programs.vim.enable = true;
	programs.vscode.enable = true;
	programs.nix-index.enable = true;

	services.gpg-agent.enable = true;

	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
		# FIXME(Krey): Using vscodium, no idea why this needs 'vscode' set
		"vscode"

		# FIXME(Krey): It's ET: Legacy, what's proprietary there?
		"etlegacy"
		"etlegacy-assets"
	];

	home.packages = [

		# Games
		aagl.anime-game-launcher # An Anime Game
		pkgs.colobot
		pkgs.etlegacy # Wolfenstein: Enemy Territory
		pkgs.airshipper # Veloren
		pkgs.mindustry
		polymc.polymc

		# Web Browsers
		pkgs.tor-browser-bundle-bin # Standard Tor Web Browser

		# Engineering
		pkgs.blender
		pkgs.kicad

		# Utility
		pkgs.bottles # Wine Management Tool
		pkgs.qbittorrent # Torrents
		pkgs.tealdeer # TLDR Pages Implementation
		pkgs.nextcloud-client

		# Gnome extensions
		pkgs.gnomeExtensions.removable-drive-menu
		pkgs.gnomeExtensions.vitals
		pkgs.gnomeExtensions.blur-my-shell
		pkgs.gnomeExtensions.gsconnect
		pkgs.gnomeExtensions.custom-accent-colors

		# FIXME_QA(Krey): Figure out how to enable this only on GNOME
		# FIXME(Krey): on NixOS 23.11 it's pinentry-gnome, but on unstable it's pinentry-gnome3
		pkgs.pinentry-gnome3
	];

	# Per-system adjustments to the GNOME Extensions
	dconf.settings = {
		# Set power management for a scenario where user is logged-in
		"org/gnome/settings-daemon/plugins/power" = {
			power-button-action = "hibernate";
			sleep-inactive-ac-timeout = 2*60*60; # 7200 Seconds -> 2 Hours
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

		"org/gnome/shell" = {
			disable-user-extensions = false;

			# The extension names can be found through `$ gnome-extensions list`
			enabled-extensions = [
				"Vitals@CoreCoding.com"
				"drive-menu@gnome-shell-extensions.gcampax.github.com"
				"blur-my-shell@aunetx"
				"user-theme@gnome-shell-extensions.gcampax.github.com"
				"gsconnect@andyholmes.github.io"
				"custom-accent-colors@demiskp"
				"desktop-cube@schneegans.github.com"
				"caffeine@patapon.info"
			];

			disabled-extensions = [];
		};
	};
}
