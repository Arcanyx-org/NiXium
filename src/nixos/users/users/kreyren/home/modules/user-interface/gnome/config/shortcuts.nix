{ lib, pkgs, config, nixosConfig, ... }:

# Kreyren's Module for Managing Keyboard Shortcuts

let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;
in mkMerge [
	{
		"${optionalString (elem release [ "24.05" "24.11" "25.05" "26.05" ]) release}" = mkIf (if elem release [ "26.05" ] then nixosConfig.services.desktopManager.gnome.enable else nixosConfig.services.xserver.desktopManager.gnome.enable) {
			# FIXME(Krey): Configure this and change the shortcuts
			home.packages = [ pkgs.gnomeExtensions.shortcuts ]; # Install an extension to show the shortcuts on demand

			dconf.settings = {
				# Keybinds -- https://discourse.nixos.org/t/nixos-options-to-configure-gnome-keyboard-shortcuts/7275/4
					"org/gnome/shell/keybinds" = {
						# To fix conflict with keybinding of flameshot
							# show-screenshot-ui = [ "<Control>Print" ];
							show-screenshot-ui = [ ];
					};

					"org/gnome/settings-daemon/plugins/media-keys" = {
						custom-keybindings = [
							"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
							"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
							"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
							"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
							"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
						];
					};

					# Terminal
					"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
						name = "Open Terminal";
						command = "${pkgs.alacritty}/bin/alacritty";
						binding = "<Super>Return";
					};

					# Web Browser
					"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
						name = "Open Web Browser";
						# command = "${pkgs.firefox-esr}/bin/firefox-esr";
						command = "${pkgs.firefox}/bin/firefox";
						binding = "<Super>t";
					};

					# File Browser
					"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
						name = "Open File Browser";
						command = "${pkgs.nautilus}/bin/nautilus";
						binding = "<Super>e";
					};

					# xkill
					"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
						name = "xkill";
						command = "${pkgs.xkill}/bin/xkill";
						binding = "<Control>Escape";
					};

					# Flameshot GUI
					"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
						name = "Gradia GUI";
						command = "${pkgs.gradia}/bin/gradia --screenshot=INTERACTIVE";
						binding = "<Control>Print";
					};
			};
		};
		"25.11" = mkIf nixosConfig.services.desktopManager.gnome.enable {
			# FIXME(Krey): Configure this and change the shortcuts
			home.packages = [ pkgs.gnomeExtensions.shortcuts ]; # Install an extension to show the shortcuts on demand

			dconf.settings = {
				# Keybinds -- https://discourse.nixos.org/t/nixos-options-to-configure-gnome-keyboard-shortcuts/7275/4
					"org/gnome/shell/keybinds" = {
						# To fix conflict with keybinding of flameshot
							# show-screenshot-ui = [ "<Control>Print" ];
							show-screenshot-ui = [ ];
					};

					"org/gnome/settings-daemon/plugins/media-keys" = {
						custom-keybindings = [
							"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
							"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
							"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
							"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
							"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
						];
					};

					# Terminal
					"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
						name = "Open Terminal";
						command = "${pkgs.alacritty}/bin/alacritty";
						binding = "<Super>Return";
					};

					# Web Browser
					"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
						name = "Open Web Browser";
						# command = "${pkgs.firefox-esr}/bin/firefox-esr";
						command = "${pkgs.firefox}/bin/firefox";
						binding = "<Super>t";
					};

					# File Browser
					"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
						name = "Open File Browser";
						command = "${pkgs.nautilus}/bin/nautilus";
						binding = "<Super>e";
					};

					# xkill
					"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
						name = "xkill";
						command = "${pkgs.xkill}/bin/xkill";
						binding = "<Control>Escape";
					};

					# Flameshot GUI
					"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
						name = "Gradia GUI";
						command = "${pkgs.gradia}/bin/gradia --screenshot=INTERACTIVE";
						binding = "<Control>Print";
					};
			};
		};
	}."${release}" or (throw "Release is not implemented: ${release}")
]
