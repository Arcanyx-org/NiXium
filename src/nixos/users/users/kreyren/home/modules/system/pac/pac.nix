{ lib, nixosConfig, ... }:

# Proxy Automatic Configuration Management

let
	inherit (lib) mkIf mkMerge;
in mkMerge [
	{
		home.file."proxy.pac" = {
			target = ".config/proxy.pac";
			source = ./kreyren-pac.es;
		};
	}

	# Configure GNOME to use PAC
	(mkIf nixosConfig.services.xserver.desktopManager.gnome.enable {
		dconf.settings = {
			"system/proxy" = {
				mode = "auto";
				autoconfig-url = "${./kreyren-pac.es}";
			};
		};
	})
]
