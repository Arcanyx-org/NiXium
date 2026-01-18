{ lib, nixosConfig,  ... }:

# Global User Management of Networking on GNOME

let
	inherit (lib) mkIf mkDefault;
in mkIf nixosConfig.services.desktopManager.gnome.enable {
	dconf.settings = {
		"system/proxy" = {
			mode = mkDefault "manual";
			ignore-hosts = [
				"localhost"
				"127.0.0.0/8"
				"::1"
			];
			"system/proxy/ftp".port = mkDefault "";
			"system/proxy/http".port = mkDefault "";
			"system/proxy/https".port = mkDefault "";

			# Use Tor System-Wide for now..
			"system/proxy/socks".port = "9050";
		};
	};
}
