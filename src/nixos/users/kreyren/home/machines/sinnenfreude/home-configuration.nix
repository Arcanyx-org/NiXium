{ pkgs, lib, unstable, aagl, ... }:

{
	home.stateVersion = "24.05";

	gtk.enable = true;

	home.impermanence.enable = true;

	programs.alacritty.enable = true; # Rust-based Video-accelarated terminal
	# FIXME(Krey): Doesn't work with scaling below 100% on GNOME
	programs.kitty.enable = false; # Alternative Rust-based Hardware-accelarated terminal for testing, potentially superrior to alacritty
	programs.bash.enable = true;
	programs.starship.enable = true;
	programs.direnv.enable = true; # To manage git repositories
	programs.git.enable = true; # Generic use only
	programs.gpg.enable = true;
	programs.firefox.enable = true;
	programs.librewolf.enable = true;
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
		# Instant-Chats
			# FIXME-QA(Krey): Use this on GTK-based desktop environments
				pkgs.fractal # GTK4+ Matrix Client Written in Rust
			# FIXME-QA(Krey): Enable this on QT-based desktop environments
				# pkgs.nheko # QT-based Matrix Client

			# Temporary management of Post-Quantum Safety until matrix manages it, see https://github.com/matrix-org/matrix-spec/issues/975 for details
			unstable.simplex-chat-desktop
			pkgs.session-desktop

			# Temporary managment of IRC until it's implemented in our matrix server
			pkgs.hexchat # Unmaintained package, no better known for the protocol

			# Discord client for flexibility
			pkgs.dissent

		# Slicers
		pkgs.cura
		pkgs.prusa-slicer
		pkgs.orca-slicer # Prusa-slicer fork by BambuLab adapted by the community

		# Games
		aagl.anime-game-launcher # An Anime Game
		pkgs.colobot
		pkgs.etlegacy # Wolfenstein: Enemy Territory
		pkgs.airshipper # Veloren
		pkgs.mindustry

		# Web Browsers
		pkgs.tor-browser-bundle-bin

		# Engineering
		pkgs.blender
		pkgs.freecad
		pkgs.gimp
		pkgs.kicad

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

		# Fonts
		# This was recommended, because nerdfonts might have issues with rendering -- https://github.com/TanvirOnGH/nix-config/blob/nix%2Bhome-manager/desktop/customization/font.nix#L4-L39
		(pkgs.nerdfonts.override { fonts = [ "Noto" "FiraCode"]; }) # Needed for starship

		# FIXME_QA(Krey): Figure out how to enable this only on GNOME
		# FIXME(Krey): on NixOS 23.11 it's pinentry-gnome, but on unstable it's pinentry-gnome3
		pkgs.pinentry-gnome3
	];

	# Per-system adjustments to the GNOME Extensions
	dconf.settings = {
		# Set power management for a scenario where user is logged-in
		"org/gnome/settings-daemon/plugins/power" = {
			power-button-action = "hibernate";
			sleep-inactive-ac-timeout = 600; # 60*10=600 Seconds -> 10 Minutes
			sleep-inactive-ac-type = "suspend";
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
