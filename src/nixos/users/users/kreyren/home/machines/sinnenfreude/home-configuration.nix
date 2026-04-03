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
		"checkra1n"

		# FIXME(Krey): Using vscodium, no idea why this needs 'vscode' set
		"vscode"

		# FIXME(Krey): It's ET: Legacy, what's proprietary there?
		"etlegacy"
		"etlegacy-assets"

		# FIXME(Krey): What the fuck? - https://www.reddit.com/r/Stremio/comments/1isd5xp/comment/mdlf66w/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
		"stremio-shell"
		"stremio-server"

		"discord"
	];

	home.packages = [
		# Instant-Chats
			# FIXME-QA(Krey): Use this on GTK-based desktop environments
				pkgs.fractal # GTK4+ Matrix Client Written in Rust

			(pkgs.goofcord.overrideAttrs (super: {
				# Force Geary to use Tor, inspired by https://discourse.nixos.org/t/using-wrapprogram-to-prefix-a-command/13862
				postInstall = (super.postInstall or "") + ''
					mv "$out/bin/goofcord" "$out/bin/.goofcord-wrapped" # Rename the old binary

					# Suffix with proxy server
					cat > "$out/bin/goofcord" <<-SCRIPT
						#!${pkgs.busybox}/bin/sh
						script_dir=\$(dirname "\$(readlink -f "\$0")")
						exec "\$script_dir/.goofcord-wrapped" --proxy-server=socks5h://127.0.0.1:25344 "\$@"
					SCRIPT

					# Ensure that it's executable
					chmod +x "$out/bin/goofcord"
				'';
			}))
			# (pkgs.dissent.overrideAttrs (super: {
			# 	# Force dissent to use Tor, inspired by https://discourse.nixos.org/t/using-wrapprogram-to-prefix-a-command/13862
			# 	nativeBuildInputs = super.nativeBuildInputs ++ [ pkgs.torsocks ];
			# 	postInstall = (super.postInstall or "") + ''
			# 		mv "$out/bin/dissent" "$out/bin/.dissent-wrapped" # Rename the old binary

			# 		# Wrap in short script that prefixes the command with `torsocks`
			# 		cat > "$out/bin/dissent" <<-SCRIPT
			# 			#!${pkgs.busybox}/bin/sh
			# 			script_dir=\$(dirname "\$(readlink -f "\$0")")
			# 			exec torsocks "\$script_dir/.dissent-wrapped" "\$@"
			# 		SCRIPT

			# 		# Ensure that it's executable
			# 		chmod +x "$out/bin/dissent"
			# 	'';
			# }))

			(pkgs.dissent.overrideAttrs (super: {
				nativeBuildInputs = (super.nativeBuildInputs or []) ++ [ pkgs.proxychains-ng ];

				postInstall = (super.postInstall or "") + builtins.concatStringsSep "\n" [
					''mv "$out/bin/dissent" "$out/bin/.dissent-wrapped"''

					''cat > "$out/bin/proxychains.conf" <<-CONF''
						''strict_chain''
						''proxy_dns''
						''remote_dns_subnet 224''
						''tcp_read_time_out 15000''
						''tcp_connect_time_out 8000''
						''[ProxyList]''
						# FIXME-SECURITY(Krey): Ideally we want to keep the ports as private and rotate them, but this is very minor security issue
						''socks5 127.0.0.1 25344''
					''CONF''

					''cat > "$out/bin/dissent" <<-SCRIPT''
						''#!${pkgs.busybox}/bin/sh''
						''exec proxychains4 -f "$out/bin/proxychains.conf" "$out/bin/.dissent-wrapped" "\$@"''
					''SCRIPT''

					''chmod +x "$out/bin/dissent"''
				];
			}))


			# Temporary management of Post-Quantum Safety until matrix manages it, see https://github.com/matrix-org/matrix-spec/issues/975 for details
			unstable.simplex-chat-desktop

			unstable.signal-desktop

			pkgs.thunderbird-esr

			# Session uses system proxy by default which breaks functionality
			# (pkgs.session-desktop.overrideAttrs (super: {
			# 	postInstall = ''
			# 		wrapProgram $out/bin/session-desktop \
			# 			--append-flags "--no-proxy-server"
			# 	'';
			# }))
			# Temporary managment of IRC until it's implemented in our matrix server
			pkgs.hexchat # Unmaintained package, no better known for the protocol

			# Discord client for flexibility
      # pkgs.dissent

		pkgs.libreoffice

    # polymc.polymc

		# Slicers
		pkgs.prusa-slicer
		# FIXME-QA(Krey): Broken on current stable, move back when fixed
		pkgs.orca-slicer # Prusa-slicer fork by BambuLab adapted by the community
			# pkgs.cura-appimage

		# Games
		aagl.anime-game-launcher # An Anime Game
		pkgs.colobot
		pkgs.etlegacy # Wolfenstein: Enemy Territory
		pkgs.airshipper # Veloren
		pkgs.mindustry

		# Web Browsers
			# FIXME(Krey): Pending managemen: tor-browser-bundle-bin (25.05) -> tor-browser (25.11)
				pkgs.tor-browser # Standard Tor Web Browser
				# pkgs.tor-browser-bundle-bin # Standard Tor Web Browser
		(pkgs.brave.overrideAttrs (super: {
			postInstall = ''
				wrapProgram $out/bin/brave \
					--append-flags "--no-proxy-server"
			'';
		})) # Standard Insecure Web Browser

		# Engineering
		pkgs.blender
		# Nixpkgs broke file chooser, this is a temporary workaround (https://github.com/NixOS/nixpkgs/issues/467783#issuecomment-3621306981)
		(pkgs.freecad.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.wrapGAppsHook3 ];
    }))
		pkgs.gimp
		pkgs.kicad-small

		# iOS Stuff
		pkgs.libimobiledevice
    pkgs.ifuse
    pkgs.checkra1n
    pkgs.libusbmuxd

		# Secrets
			# pkgs.keepassxc
			pkgs.gnome-secrets

		# Utility
		pkgs.localsend
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
		unstable.hydralauncher
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

		# Video
    #pkgs.stremio # Media Server Client
		pkgs.freetube # YouTube Client
		pkgs.mpv
		pkgs.vlc
		# pkgs.stremio
		pkgs.gnome-network-displays

		# Gnome extensions
		pkgs.gnomeExtensions.removable-drive-menu
		pkgs.gnomeExtensions.vitals
		pkgs.gnomeExtensions.blur-my-shell
		pkgs.gnomeExtensions.gsconnect

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
			position-in-panel = 2;
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
