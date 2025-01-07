{ lib, nixosConfig, ... }:

# Kreyren's Module for Various Usability Tweaks on GNOME

let
	inherit (lib) mkIf mkMerge;
in mkIf nixosConfig.services.xserver.desktopManager.gnome.enable (mkMerge [
	# Common Configuration across multiple GNOME releases
		{
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
					];
				};
			};
		}
])
