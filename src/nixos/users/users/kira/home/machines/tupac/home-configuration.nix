{ config, pkgs, lib, aagl, aagl-unstable, unstable, polymc, self, ... }:

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

		"vscode"
		"etlegacy"
		"etlegacy-assets"

		"discord"

		# FIXME(Krey): What the fuck? - https://www.reddit.com/r/Stremio/comments/1isd5xp/comment/mdlf66w/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
		"stremio-shell"
		"stremio-server"

		# alpaka
		"cuda_cudart"
		"libcublas"
		"cuda_cccl"
		"cuda_nvcc"
	];

	home.packages = [
		pkgs.fractal
		pkgs.goofcord
		(pkgs.dissent.overrideAttrs (super: {
			# Force dissent to use Tor, inspired by https://discourse.nixos.org/t/using-wrapprogram-to-prefix-a-command/13862
			nativeBuildInputs = super.nativeBuildInputs ++ [ pkgs.torsocks ];
			postInstall = (super.postInstall or "") + ''
				mv "$out/bin/dissent" "$out/bin/.dissent-wrapped" # Rename the old binary

				# Wrap in short script that prefixes the command with `torsocks`
				cat > "$out/bin/dissent" <<-SCRIPT
					#!${pkgs.busybox}/bin/sh
					script_dir=\$(dirname "\$(readlink -f "\$0")")
					exec torsocks "\$script_dir/.dissent-wrapped" "\$@"
				SCRIPT

				# Ensure that it's executable
				chmod +x "$out/bin/dissent"
			'';
		}))
		unstable.simplex-chat-desktop
		unstable.signal-desktop
		pkgs.hexchat

		# Slicers
		pkgs.prusa-slicer
		# FIXME-QA(Krey): Broken on current stable, move back when fixed .. and on unstable bcs libsoup2
			# unstable.orca-slicer # Prusa-slicer fork by BambuLab adapted by the community

		# Games
		aagl.anime-game-launcher # An Anime Game
		pkgs.colobot # Colobot
		pkgs.etlegacy # Wolfenstein: Enemy Territory
		pkgs.airshipper # Veloren
		pkgs.mindustry # Mindustry
		polymc.polymc # Minecraft

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
		(pkgs.bottles.override { removeWarningPopup = true; }) # Wine Management Tool
		pkgs.mtr # Packet Loss Tester
		pkgs.sc-controller # Steam Controller Software
		pkgs.monero-gui
		pkgs.dialect # Language Translator
		pkgs.endeavour # To-Do Notes
		pkgs.kooha # Screen Recorder
		pkgs.qbittorrent # Torrents
		pkgs.tealdeer # TLDR Pages Implementation
		pkgs.nextcloud-client
		pkgs.moonlight-qt
		pkgs.libreoffice
		pkgs.gnome-decoder
		unstable.hydralauncher
		unstable.nexusmods-app
		pkgs.flashrom
		(pkgs.alpaca.override { ollama = pkgs.ollama-cuda; })
		(pkgs.geary.overrideAttrs (super: {
			# Force Geary to use Tor, inspired by https://discourse.nixos.org/t/using-wrapprogram-to-prefix-a-command/13862
			nativeBuildInputs = super.nativeBuildInputs ++ [ pkgs.torsocks ];
			postInstall = (super.postInstall or "") + ''
				mv "$out/bin/geary" "$out/bin/.geary-wrapped" # Rename the old binary

				# Wrap in short script that prefixes the command with `torsocks`
				cat > "$out/bin/geary" <<-SCRIPT
					#!${pkgs.busybox}/bin/sh
					script_dir=\$(dirname "\$(readlink -f "\$0")")
					exec torsocks "\$script_dir/.geary-wrapped" "\$@"
				SCRIPT

				# Ensure that it's executable
				chmod +x "$out/bin/geary"
			'';
		}))

		pkgs.nmap

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
			position-in-panel = 1;
			show-battery = true;
			show-gpu = true;
			update-time = 3;
			use-higher-precision = true;

			hot-sensors = [
				"_system_load_1m_"
				"_memory_usage_"
				"_temperature_acpi_thermal zone_" # Hot Spot Temperature
				"_gpu#1_temperature_"
				"__network-rx_max__"
				"__network-tx_max__"
				"_storage_free_" # To show remaining in impermanence
				"_voltage_bat0_in0_" # Show the rate of (dis)charging
				"_battery_time_left_"
			];
		};

		"org/gnome/desktop/screen-time-limits" = {
			# FIXME(Krey): It's broken and constantly sets my display into grayscale even when it's new day
			daily-limit-enabled = false;
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
				# FIXME(Krey): Not valid for 25.05, needs to be release-managed
				# "custom-accent-colors@demiskp"
				"desktop-cube@schneegans.github.com"
				"caffeine@patapon.info"
			];

			disabled-extensions = [];
		};
	};
}
