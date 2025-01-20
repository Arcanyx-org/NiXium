{ self, config, pkgs, lib, unstable, aagl, polymc, nixosConfig, ... }:

let
	inherit (lib) mkIf;
in {
	gtk.enable = true;

	home.impermanence.enable = true;

	programs.alacritty.enable = true; # Rust-based Video-accelarated terminal
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
		polymc.polymc
		self.inputs.aagl.packages.x86_64-linux.anime-game-launcher

		# Utility
		pkgs.keepassxc
		pkgs.yt-dlp
		pkgs.bottles # Wine Management Tool
		pkgs.mtr # Packet Loss Tester
		pkgs.sc-controller # Steam Controller Software

		# Gnome extensions
			# FIXME(Krey): Apply this only when GNOME is enabled system-wide
			# pkgs.gnomeExtensions.removable-drive-menu
			# pkgs.gnomeExtensions.vitals
			# pkgs.gnomeExtensions.blur-my-shell
			# pkgs.gnomeExtensions.gsconnect
			# pkgs.gnomeExtensions.custom-accent-colors

		# Fonts
		# This was recommended, because nerdfonts might have issues with rendering -- https://github.com/TanvirOnGH/nix-config/blob/nix%2Bhome-manager/desktop/customization/font.nix#L4-L39
		(pkgs.nerdfonts.override { fonts = [ "Noto" "FiraCode"]; }) # Needed for starship
	];

	# Per-system adjustments to the GNOME Extensions
	dconf.settings = mkIf nixosConfig.services.xserver.desktopManager.gnome.enable {
		# Set power management for a scenario where user is logged-in
		"org/gnome/settings-daemon/plugins/power" = {
			power-button-action = "hibernate";
			sleep-inactive-ac-timeout = 600; # 60*10=600 Seconds -> 10 Minutes
			sleep-inactive-ac-type = "suspend";
		};

		"org/gnome/shell" = {
			disable-user-extensions = false; # Allow User Extensions

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

	# Kodi
	programs.kodi = {
		enable = mkIf nixosConfig.services.xserver.desktopManager.kodi.enable true; # Enable Kodi Management if it's enabled system-wide
		# Reference: https://kodi.wiki/view/Advancedsettings.xml
		settings = { };
		addonSettings = {
			"service.xbmc.versioncheck".versioncheck_enable = "false"; # Disable version-check as nix is responsible for it's management
		};
		# Reference: https://kodi.wiki/view/Sources.xml
		sources = { };
	};
}
