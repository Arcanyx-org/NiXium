{ config, pkgs, lib, aagl, aagl-unstable, unstable, polymc, ... }:

let
	inherit (lib) mkIf;
in {
	gtk.enable = true;

	home.impermanence.enable = true;

	programs.alacritty.enable = true; # Rust-based Hardware-accelarated terminal
	programs.kitty.enable = false; # Alternative Rust-based Hardware-accelarated terminal for testing, potentially superrior to alacritty
	programs.bash.enable = true;
	programs.starship.enable = true;
	programs.direnv.enable = true; # To manage git repositories
	programs.git.enable = true; # Generic use only
	programs.gpg.enable = true;
	programs.firefox.enable = true;
	programs.vim.enable = true;
	programs.vscode.enable = true; # Generic use only

	services.gpg-agent.enable = (mkIf config.programs.gpg.enable true);

	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
		"checkra1n"

		"discord"

		# FIXME(Krey): What the fuck? - https://www.reddit.com/r/Stremio/comments/1isd5xp/comment/mdlf66w/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
		"stremio-shell"
		"stremio-server"

		# FIXME(Krey): Using vscodium, no idea why this needs 'vscode' set
		"vscode"

		# FIXME(Krey): It's ET: Legacy, what's proprietary there?
		"etlegacy"
		"etlegacy-assets"
	];

	home.packages = [
		pkgs.fractal
		pkgs.discord
		pkgs.dissent
		unstable.simplex-chat-desktop
		unstable.signal-desktop
		pkgs.hexchat

		# Slicers
		pkgs.prusa-slicer
		# FIXME-QA(Krey): Broken on current stable, move back when fixed
			unstable.orca-slicer # Prusa-slicer fork by BambuLab adapted by the community

		# Games
		aagl.anime-game-launcher # An Anime Game
		pkgs.colobot # Colobot
		pkgs.etlegacy # Wolfenstein: Enemy Territory
		pkgs.airshipper # Veloren
		pkgs.mindustry # Mindustry
		# polymc.polymc # Minecraft

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
		pkgs.kicad

		# iOS Stuff
		pkgs.libimobiledevice
    pkgs.ifuse
    pkgs.checkra1n
    pkgs.libusbmuxd

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
		pkgs.kooha # Screen Recorder
		pkgs.qbittorrent # Torrents
		pkgs.tealdeer # TLDR Pages Implementation
		pkgs.nextcloud-client
		# FIXME(Krey): To be managed..
		#(mkIf (config.system.nixos.release != "24.11") pkgs.printrun) # Currently broken in unstable+
		pkgs.moonlight-qt
		pkgs.libreoffice
		pkgs.gnome-decoder
		unstable.hydralauncher
		unstable.nexusmods-app
		pkgs.flashrom

		# Emulators
		# pkgs.mame # Arcade Games

		# pkgs.dosbox-x # DOS

		pkgs.duckstation # PlayStation 1
		# pkgs.pcsx2 # PlayStation 2
		# pkgs.rpcs3 # PlayStation 3
		# pkgs.ppsspp-qt # PlayStation Portable

		# pkgs.azahar # Nintendo 3DS
		# pkgs.rmg # Nintendo 64
		# pkgs.melonDS # Nintendo DS
		# pkgs.fceux # Nintendo Entertainment System
		# pkgs.sameboy # Nintendo Game Boy & Game Boy Color
		# pkgs.mgba # Nintendo Game Boy Advance
		# pkgs.dolphin-emu # Nintendo GameCube & Wii
		# pkgs.cemu # Nintendo Wii U
		# pkgs.ryujinx-greemdev # Nintendo Switch
		# pkgs.snes9x-gtk # Super Nintendo Entertainment System

		# pkgs.blastem # Sega Genesis / Megadrive
		# pkgs.flycast # Sega Dreamcast, Naomi/2 and Atomiswave
		# pkgs.mednafen # Sega Saturn (Many others supported)
		# pkgs.mednaffe # GTK-based frontend for mednafen emulator

    # pkgs.xemu # Xbox

		# Video
		pkgs.stremio # Media Server Client
		pkgs.freetube # YouTube Client
		pkgs.mpv
		pkgs.vlc

		# Gnome extensions
		pkgs.gnomeExtensions.removable-drive-menu
		pkgs.gnomeExtensions.vitals
		pkgs.gnomeExtensions.blur-my-shell
		pkgs.gnomeExtensions.gsconnect
		pkgs.gnomeExtensions.custom-accent-colors

		# FIXME_QA(Krey): Figure out how to enable this only on GNOME
		# FIXME(Krey): on NixOS 23.11 it's pinentry-gnome, but on unstable it's pinentry-gnome3
		pkgs.pinentry-gnome3

		# WINEHQ Experiments
    pkgs.wineWowPackages.stagingFull
	];

	# GNOME Extensions
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
			hide-icons = false;
			hide-zeros = false;
			icon-style = 1;
			include-static-info = false;
			menu-centered = false;
			network-speed-format = 1;
			position-in-panel = 2;
			show-battery = true;
			show-gpu = true;
			update-time = 3;
			use-higher-precision = true;

			hot-sensors = [
				"_memory_usage_"
				"_system_load_1m_"
				"__temperature_avg__"
				"_temperature_gpu_"
				"_voltage_bat0_in0_"
				"__network-rx_max__"
				"__network-tx_max__"
				"_storage_free_"
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
