{ config, pkgs, lib, aagl, aagl-unstable, unstable, self, ... }:

let
	inherit (lib) mkIf;
in {
	gtk.enable = true;

	home.impermanence.enable = true;

	programs.alacritty.enable = true;
	programs.kitty.enable = false;
	programs.bash.enable = true;
	programs.starship.enable = true;
	programs.direnv.enable = true;
	programs.git.enable = true;
	programs.gpg.enable = true;
	programs.firefox.enable = true;
	programs.vim.enable = true;
	programs.vscodium.enable = true;

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
		(pkgs.goofcord.overrideAttrs (super: {
			postInstall = (super.postInstall or "") + ''
				mv "$out/bin/goofcord" "$out/bin/.goofcord-wrapped"
				cat > "$out/bin/goofcord" <<-SCRIPT
					#!${pkgs.busybox}/bin/sh
					script_dir=\$(dirname "\$(readlink -f "\$0")")
					exec "\$script_dir/.goofcord-wrapped" --proxy-server=socks5h://127.0.0.1:25344 "\$@"
				SCRIPT
				chmod +x "$out/bin/goofcord"
			'';
		}))
		(pkgs.dissent.overrideAttrs (super: {
			nativeBuildInputs = super.nativeBuildInputs ++ [ pkgs.torsocks ];
			postInstall = (super.postInstall or "") + ''
				mv "$out/bin/dissent" "$out/bin/.dissent-wrapped"
				cat > "$out/bin/dissent" <<-SCRIPT
					#!${pkgs.busybox}/bin/sh
					script_dir=\$(dirname "\$(readlink -f "\$0")")
					exec torsocks "\$script_dir/.dissent-wrapped" "\$@"
				SCRIPT
				chmod +x "$out/bin/dissent"
			'';
		}))
		unstable.simplex-chat-desktop
		unstable.signal-desktop
		pkgs.hexchat

		pkgs.prusa-slicer

		aagl.anime-game-launcher
		pkgs.colobot
		pkgs.etlegacy
		pkgs.airshipper
		pkgs.mindustry
		pkgs.prismlauncher

		# pkgs.tor-browser-bundle-bin
		pkgs.tor-browser
		(pkgs.brave.overrideAttrs (super: {
			postInstall = ''
				wrapProgram $out/bin/brave \
					--append-flags "--no-proxy-server"
			'';
		}))

		pkgs.blender
		# (pkgs.freecad.overrideAttrs (old: {
    #   nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.wrapGAppsHook3 ];
    # }))
		pkgs.gimp
		pkgs.kicad-small

		pkgs.libimobiledevice
    pkgs.ifuse
    pkgs.checkra1n
    pkgs.libusbmuxd

		pkgs.keepassxc
		pkgs.yt-dlp
		pkgs.android-tools
		pkgs.picocom
		(pkgs.bottles.override { removeWarningPopup = true; })
		pkgs.mtr
		pkgs.sc-controller
		pkgs.monero-gui
		pkgs.dialect
		pkgs.endeavour
		pkgs.kooha
		pkgs.qbittorrent
		pkgs.tealdeer
		pkgs.nextcloud-client
		pkgs.moonlight-qt
		pkgs.libreoffice
		pkgs.gnome-decoder
		unstable.hydralauncher
		# unstable.nexusmods-app — discontinued upstream, marked insecure
		pkgs.flashrom
		# (pkgs.alpaca.override { ollama = pkgs.ollama-cuda; })
		(pkgs.geary.overrideAttrs (super: {
			nativeBuildInputs = super.nativeBuildInputs ++ [ pkgs.torsocks ];
			postInstall = (super.postInstall or "") + ''
				mv "$out/bin/geary" "$out/bin/.geary-wrapped"
				cat > "$out/bin/geary" <<-SCRIPT
					#!${pkgs.busybox}/bin/sh
					script_dir=\$(dirname "\$(readlink -f "\$0")")
					exec torsocks "\$script_dir/.geary-wrapped" "\$@"
				SCRIPT
				chmod +x "$out/bin/geary"
			'';
		}))

		pkgs.nmap

		pkgs.gnomeExtensions.removable-drive-menu
		pkgs.gnomeExtensions.vitals
		pkgs.gnomeExtensions.blur-my-shell
		pkgs.gnomeExtensions.gsconnect

		pkgs.pinentry-gnome3

    pkgs.wineWow64Packages.stagingFull
	];

	dconf.settings = {
		# Disable DWP, because it makes gaming with touchpad pretty annoying
		"org/gnome/desktop/peripherals/touchpad" = {
			disable-while-typing = false;
		};
		"org/gnome/settings-daemon/plugins/power" = {
			power-button-action = "hibernate";
			sleep-inactive-ac-timeout = 2*60*60;
			sleep-inactive-ac-type = "suspend";
		};

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
				"_temperature_acpi_thermal zone_"
				"_gpu#1_temperature_"
				"__network-rx_max__"
				"__network-tx_max__"
				"_storage_free_"
				"_voltage_bat0_in0_"
				"_battery_time_left_"
			];
		};

		"org/gnome/desktop/screen-time-limits" = {
			daily-limit-enabled = false;
		};

		"org/gnome/shell" = {
			disable-user-extensions = false;

			enabled-extensions = [
				"Vitals@CoreCoding.com"
				"drive-menu@gnome-shell-extensions.gcampax.github.com"
				"blur-my-shell@aunetx"
				"user-theme@gnome-shell-extensions.gcampax.github.com"
				"gsconnect@andyholmes.github.io"
				"desktop-cube@schneegans.github.com"
				"caffeine@patapon.info"
			];

			disabled-extensions = [];
		};
	};
}
