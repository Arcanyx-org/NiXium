{ lib, nixosConfig, ... }:

# Kreyren's Module for Language Input on GNOME

# TODO(Krey): Implement Weeb Mode

let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;

	inherit (lib.hm.gvariant) mkTuple;
in mkMerge [
	{
		"${optionalString (elem release [ "24.05" "24.11" "25.05" "26.05" ]) release}" = mkIf (if elem release [ "26.05" ] then nixosConfig.services.desktopManager.gnome.enable else nixosConfig.services.xserver.desktopManager.gnome.enable) {
			dconf.settings = {
				# Keyboard Input Adjustments
					"org/gnome/desktop/input-sources" = {
						shob-all-sources = true;
						sources = [
							(mkTuple [ "xkb" "us" ]) # Standard US Keyboard
							(mkTuple [ "xkb" "cz+qwerty" ]) # Standard Czech Keyboard
						];
						xkb-options = [ "terminate:ctrl_alt_bksp" ];
					};
			};
		};
		"25.11" = mkIf nixosConfig.services.desktopManager.gnome.enable {
			dconf.settings = {
				# Keyboard Input Adjustments
					"org/gnome/desktop/input-sources" = {
						shob-all-sources = true;
						sources = [
							(mkTuple [ "xkb" "us" ]) # Standard US Keyboard
							(mkTuple [ "xkb" "cz+qwerty" ]) # Standard Czech Keyboard
						];
						xkb-options = [ "terminate:ctrl_alt_bksp" ];
					};
			};
		};
	}."${release}" or (throw "Release is not implemented: ${release}")
]
