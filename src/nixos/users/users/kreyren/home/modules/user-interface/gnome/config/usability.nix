{ lib, nixosConfig, ... }:

# Kreyren's Module for Various Usability Tweaks on GNOME

let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;
in mkMerge [
	{
		"${optionalString (elem release [ "24.05" "24.11" "25.05" "26.05" ]) release}" = mkIf (if elem release [ "26.05" ] then nixosConfig.services.desktopManager.gnome.enable else nixosConfig.services.xserver.desktopManager.gnome.enable) {
			dconf.settings = {
				# FIXME(Krey): Figure out how to do more than 150%
				"org/gnome/desktop/sound".allow-volume-above-100-percent = true; # Over-Amplification

				# Button Modifier for resizing with mouse
					"org/gnome/desktop/wm/preferences" = {
						mouse-button-modifier = "<Alt>"; # Use the Meta Key instead of Super
						resize-with-right-button = true;
					};

				"org/gnome/desktop/interface" = {
					enable-hot-corners = true; # Hot Corner to use GNOME only with mouse if needs be
					clock-show-seconds = true; # Show seconds in the clock widget
					show-battery-percentage = true; # Show battery capacity in the bar
				};

				"org/gnome/mutter" = {
					dynamic-workspaces=true;
					workspaces-only-on-primary=false;
					experimental-features = [
						"scale-monitor-framebuffer" # Enable Fractional Scaling
						"variable-refresh-rate" # https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1154
						"xwayland-native-scaling" # To avoid false resolution in combination with fractional scaling
					];
				};
			};
		};
		"25.11" = mkIf nixosConfig.services.desktopManager.gnome.enable {
			dconf.settings = {
				# FIXME(Krey): Figure out how to do more than 150%
				"org/gnome/desktop/sound".allow-volume-above-100-percent = true; # Over-Amplification

				# Button Modifier for resizing with mouse
					"org/gnome/desktop/wm/preferences" = {
						mouse-button-modifier = "<Alt>"; # Use the Meta Key instead of Super
						resize-with-right-button = true;
					};

				"org/gnome/desktop/interface" = {
					enable-hot-corners = true; # Hot Corner to use GNOME only with mouse if needs be
					clock-show-seconds = true; # Show seconds in the clock widget
					show-battery-percentage = true; # Show battery capacity in the bar
				};

				"org/gnome/mutter" = {
					dynamic-workspaces=true;
					workspaces-only-on-primary=false;
					experimental-features = [
						"scale-monitor-framebuffer" # Enable Fractional Scaling
						"variable-refresh-rate" # https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1154
						"xwayland-native-scaling" # To avoid false resolution in combination with fractional scaling
					];
				};
			};
		};
	}."${release}" or (throw "Release is not implemented: ${release}")
]
