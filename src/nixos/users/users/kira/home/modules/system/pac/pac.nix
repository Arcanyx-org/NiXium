{ lib, nixosConfig, ... }:

# Proxy Automatic Configuration Management

let
	inherit (lib) elem mkIf mkMerge;
	inherit (lib.trivial) release;
in mkMerge [
	{
		home.file."proxy.pac" = {
			target = ".config/proxy.pac";
			source = ./kira-pac.es;
		};
	}

	# Configure GNOME to use PAC
	(mkIf (if elem release [ "26.05" ] then nixosConfig.services.desktopManager.gnome.enable else nixosConfig.services.xserver.desktopManager.gnome.enable) {
		dconf.settings = {
			"system/proxy" = {
				mode = "auto";
				autoconfig-url = "${./kira-pac.es}";
			};
		};
	})
]
