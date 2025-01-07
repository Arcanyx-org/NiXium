{ config, pkgs, lib, unstable, aagl, polymc, ... }:

# FIXME(Krey): trace: evaluation warning: The ‘gnome.dconf-editor’ was moved to top-level. Please use ‘pkgs.dconf-editor’ directly. -- Channel 24.11

let
	inherit (lib) mkIf;
in {
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

		"discord"
	];

	home.packages = [
		# Instant-Chats
			# FIXME-QA(Krey): Use this on GTK-based desktop environments
				pkgs.fractal # GTK4+ Matrix Client Written in Rust
			# FIXME-QA(Krey): Enable this on QT-based desktop environments
				# pkgs.nheko # QT-based Matrix Client

			# PRIVACY(Krey): Temporary management with adjusted threat model used only as a fallback in case webcord fails in production
			(pkgs.discord.overrideAttrs (super: {
				postInstall = ''
					wrapProgram $out/bin/discord \
						--append-flags "--no-proxy-server"

					wrapProgram $out/bin/Discord \
						--append-flags "--no-proxy-server"
				'';
			}))

			pkgs.nss

			# Temporary management of Post-Quantum Safety until matrix manages it, see https://github.com/matrix-org/matrix-spec/issues/975 for details
			unstable.simplex-chat-desktop

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

		polymc.polymc

		# Slicers
		pkgs.prusa-slicer
		pkgs.super-slicer-beta # Prusa-slicer fork by community. Includes additional features, but lags behind in releases
		pkgs.orca-slicer # Prusa-slicer fork by BambuLab adapted by the community

		# Games
		aagl.anime-game-launcher # An Anime Game
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
		pkgs.kooha # Screen Recorder
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

		# Gnome extensions
		pkgs.gnomeExtensions.removable-drive-menu
		pkgs.gnomeExtensions.vitals
		pkgs.gnomeExtensions.blur-my-shell
		pkgs.gnomeExtensions.gsconnect
		pkgs.gnomeExtensions.custom-accent-colors

		# Fonts
		# This was recommended, because nerdfonts might have issues with rendering -- https://github.com/TanvirOnGH/nix-config/blob/nix%2Bhome-manager/desktop/customization/font.nix#L4-L39
		(pkgs.nerd-fonts.override { fonts = [ "Noto" "FiraCode"]; }) # Needed for starship

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
