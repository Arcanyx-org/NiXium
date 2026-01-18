{ lib, nixosConfig,  ... }:

# Global User Management of Networking on GNOME

let
	inherit (lib) mkIf mkDefault;
	inherit (lib.hm.gvariant) mkValue mkString mkStrv;
in mkIf nixosConfig.services.desktopManager.gnome.enable {
	dconf.settings = {
		"system/proxy" = {
			mode = mkDefault "manual";

			ignore-hosts = [
			"localhost"
			"127.0.0.0/8"
			"::1"
		];
		};

		"system/proxy/ftp" = {
			host = "127.0.0.1";
			port = mkDefault "0";
		};

		"system/proxy/http" = {
			host = "127.0.0.1";
			port = mkDefault 0;
		};

		"system/proxy/https" = {
			host = "127.0.0.1";
			port = mkDefault 0;
		};

		"system/proxy/socks" = {
			host = "127.0.0.1";
			port = 9050; # Use Tor System-Wide for now..
		};
	};
}
