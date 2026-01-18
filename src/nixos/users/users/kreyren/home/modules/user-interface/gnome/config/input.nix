{ lib, nixosConfig, ... }:

# Kreyren's Module for Language Input on GNOME

# TODO(Krey): Implement Weeb Mode

let
	inherit (lib) mkIf mkMerge;
	inherit (lib.hm.gvariant) mkTuple;
in mkIf nixosConfig.services.xserver.desktopManager.gnome.enable (mkMerge [
	# Common Configuration across multiple GNOME releases
		{
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
		}
])
